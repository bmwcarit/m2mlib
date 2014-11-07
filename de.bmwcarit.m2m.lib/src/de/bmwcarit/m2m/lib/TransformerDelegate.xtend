/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib

import de.bmwcarit.m2m.lib.annotations.Transform
import de.bmwcarit.m2m.lib.annotations.Transformer
import java.lang.reflect.Method
import java.util.Collection
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Set

class TransformerDelegate {
	static val INVALID = "_INVALID_"
	static val INCOMPATIBLE_TYPE = 9999
	val ITransformer target
	val Iterable<Method> transformMethods
	val Map<Pair<Class<?>, List<Class<?>>>, List<Pair<ITransformer, Method>>> transformMethodCache
	val Collection<TransformerDelegate> transformers
	var TransformerDelegate root = null
	val ITransformerObjectFactory factory
	val ITransformerObjectWrapper wrapper
	val ITransformerPreProcessor preProcessor
	val ITransformerPostProcessor postProcessor
	val ITransformerErrorHandler errorHandler
	val cache = new HashMap<Object, Object>()

	new(ITransformer target) {
		this.target = target
		this.transformMethods = target.class.declaredMethods.filter[getAnnotation(Transform) != null].toList
		this.transformers = newArrayList
		this.transformMethodCache = newHashMap
		val annotation = target.class.getAnnotation(Transformer)
		this.factory  = annotation.factory.newInstance
		this.wrapper = if (annotation.objectWrapper == ITransformerObjectWrapper) null else  annotation.objectWrapper.newInstance 
		this.preProcessor = if (annotation.preProcessor == ITransformerPreProcessor) null else  annotation.preProcessor.newInstance 
		this.postProcessor = if (annotation.postProcessor == ITransformerPostProcessor) null else  annotation.postProcessor.newInstance 
		this.errorHandler = if (annotation.errorHandler == ITransformerErrorHandler) null else  annotation.errorHandler.newInstance 
	}
	
	def <OUT> OUT map(Class<?> expectedType, Object... in) {
		// init upon first fall. we are the root transformer then :)
		if (root == null)
			initTransformers(this, newHashSet, newHashMap)
			
		// wrap objects (or take as is)
		val sources = if (wrapper == null) in.toList else in.map[wrapper.wrap(it)]

		// garbage in, garbage out
		if (sources.head == null)
			return null

		// cache lookup
		val cacheKey = expectedType->sources
		var out = root.cache.get(cacheKey)
		
		// not found => process
		if (out == null) {
			out = INVALID
			try {
				if (preProcessor == null || preProcessor.preProcess(sources)) {
					val transformers = findOrderedTransformMethods(expectedType, sources)
					if (!transformers.empty) {
						// create instance of best (i.e. most specific type)
						out = factory.createInstance(transformers.head.value.returnType) ?: INVALID
						if (out != INVALID) {
							// put in cache early so we already have an instance in re-entrant calls for the same object
							root.cache.put(cacheKey, out)
							// call all transformer in reverse order. a transformer may replace the output value, so use fold()
							out = transformers.reverseView.fold(out) [o, t |
								val args = newArrayOfSize(sources.size + 1)
								sources.toArray(args)
								args.set(sources.size, o)
								t.value.invoke(t.key, args)
							] ?: INVALID
							postProcessor?.postProcess(sources, out)
						} else {
							out = TransformerErrorCode.CREATE_INSTANCE_FAILED->null
							errorHandler?.handleError(sources, TransformerErrorCode.CREATE_INSTANCE_FAILED, null)
						}
					} else {
						out = TransformerErrorCode.NO_TRANSFORMER_FOUND->null
						errorHandler?.handleError(sources, TransformerErrorCode.NO_TRANSFORMER_FOUND, null)
					}
				} else {
					out = TransformerErrorCode.PRE_PROCESS_FAILED->null
					errorHandler?.handleError(sources, TransformerErrorCode.PRE_PROCESS_FAILED, null)
				}
			} catch (Exception x) {
				out = TransformerErrorCode.UNCAUGHT_EXCEPTION->x
				if (errorHandler== null)
					x.printStackTrace
				else
					errorHandler.handleError(sources, TransformerErrorCode.UNCAUGHT_EXCEPTION, x)
			} finally {
				root.cache.put(cacheKey, out)
			}
		} else if (out instanceof Pair<?,?> && (out as Pair<?,?>).key instanceof TransformerErrorCode) {
			// ran into problem last time, will run into same problems again. just notify error handler
			errorHandler?.handleError(sources, (out as Pair<TransformerErrorCode,?>).key, (out as Pair<?,Exception>).value)
		}
		
		// done :-)
		if (out == INVALID || (out instanceof Pair<?,?> && (out as Pair<?,?>).key instanceof TransformerErrorCode))
			null
		else
			out as OUT
	}

	def <OUT> OUT mapOne(Class<OUT> expectedType, Object source, Object... sourceArgs) {
		val a = newArrayOfSize(sourceArgs.length + 1)
		System.arraycopy(sourceArgs, 0, a, 1, sourceArgs.length)
		a.set(0, source)
		map(expectedType, a)
	}
	
	def <OUT> Iterable<OUT> mapAll(Class<OUT> expectedType, Iterable<?> source, Object... sourceArgs) {
		source.map[
			val a = newArrayOfSize(sourceArgs.length + 1)
			System.arraycopy(sourceArgs, 0, a, 1, sourceArgs.length)
			a.set(0, it)
			map(expectedType, a)
		].filterNull
		// eager evaluation because if the caller never processes the list, the transformation is effectively not called at all
		.toList
	}
	
	def getObjectWrapper() {
		wrapper
	}
	
	def getPreProcessor() {
		preProcessor
	}

	def getPostProcessor() {
		postProcessor
	}
	
	def getErrorHandler() {
		errorHandler
	}
	
	def getRoot() {
		root
	}
	
	def getRelatedTransformers() {
		transformers
	}
	
	/**
	 * Look for fields of type ITransformer. Do this recursively. We will check their transform methods, too.
	 */
	def void initTransformers(TransformerDelegate root, Set<TransformerDelegate> visited, Map<Class<? extends ITransformer>, TransformerDelegate> visitedTypes) {
		if (visited.add(this)) {
			this.root = root
			// add transformers from annotation. create one instance per type and reuse it
			transformers += target.class.getAnnotation(Transformer).uses.map[ t |
				if (visitedTypes.containsKey(t))
					visitedTypes.get(t)
				else
					t.newInstance.transformerDelegate => [ d |
						visitedTypes.put(t, d)
						d.initTransformers(root, visited, visitedTypes)
					]
			]
			// add transformers from fields
			transformers += target.class.declaredFields.filter[typeof(ITransformer).isAssignableFrom(type)].map[
				accessible = true
				(get(target) as ITransformer).transformerDelegate => [ it.initTransformers(root, visited, visitedTypes) ]
			]
		}
	}

	/**
	 * Best matching transform method is the one with the lowest score. Ordered by score.
	 */
	def protected findOrderedTransformMethods(Class<?> expectedType, Iterable<Object> in) {
		val cacheKey = expectedType->in.map[it?.class].toList
		transformMethodCache.get(cacheKey) ?: {
			// lookup
			findTransformMethods(cacheKey.value, newHashSet)
			// sort by arguments
			.sortBy[key].filter[key<INCOMPATIBLE_TYPE].map[value]
			// filter incompatible return types
			.filter[expectedType == null || score(value.returnType, expectedType, 0) < INCOMPATIBLE_TYPE]
			// create list eagerly so we can reverse more efficiently later
			.toList 
			// put in cache
			=> [ transformMethodCache.put(cacheKey, it) ]
		}
	}
	
	/**
	 * Finds all matching methods in all associated transformers. Computes score on-the-fly.
	 */
	def Iterable<Pair<Integer, Pair<ITransformer, Method>>> findTransformMethods(List<Class<?>> inTypes, Set<TransformerDelegate> visited) {
		// break cycle in transformer object graph
		if (visited.contains(this))
			emptyList
		else
			transformMethods.filter[
				parameterTypes.size == inTypes.size+1
			].map[
				it.score(inTypes) -> ( target -> it)
			]
			+
			transformers.map[it.findTransformMethods(inTypes, visited => [add(this)])].flatten
	}
	
	/**
	 * The score of a method is the sum of the score of its parameters.
	 */
	def protected score(Method m, List<Class<?>> actualTypes) {
		(0..actualTypes.size-1).map[i |
			score(m.parameterTypes.get(i), actualTypes.get(i), 0) 
		].reduce[a,b | a + b]
	}
	
	/**
	 * The score of a parameter is the minimum "distance" of the type to the expected (actual) type.
	 */
	def protected int score(Class<?> parameterType, Class<?> actualType, int depth) {
		if (actualType == null || parameterType == actualType)
			depth
		else
			(#[actualType.superclass] + actualType.interfaces).filterNull.map[score(parameterType, it, depth+1)].sort.head ?: INCOMPATIBLE_TYPE
	}
}
