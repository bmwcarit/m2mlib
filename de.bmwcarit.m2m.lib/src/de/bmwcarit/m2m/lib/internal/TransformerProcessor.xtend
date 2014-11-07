/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib.internal

import de.bmwcarit.m2m.lib.ITransformer
import de.bmwcarit.m2m.lib.TransformerDelegate
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

class TransformerProcessor extends AbstractClassProcessor  {
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[findTypeGlobally(ITransformer).newTypeReference]
		annotatedClass.addField("delegate") [
			type = findTypeGlobally(TransformerDelegate).newTypeReference
			initializer = [
				'''new TransformerDelegate(this)'''
			]
		]
		annotatedClass.addMethod("getTransformerDelegate") [
			returnType = findTypeGlobally(TransformerDelegate).newTypeReference
			body = [
				'''return delegate;'''
			]
		]
		annotatedClass.addMethod("map") [
			returnType = addTypeParameter("T", object).newTypeReference
			addParameter("source", object)
			addParameter("sourceArgs", object.newArrayTypeReference)
			varArgs = true
			body = [
				'''return delegate.mapOne(null, source, sourceArgs);'''
			]
		]
		annotatedClass.addMethod("mapAs") [
			val t = addTypeParameter("T", object)
			returnType = t.newTypeReference
			addParameter("source", object)
			addParameter("type", findTypeGlobally(Class).newTypeReference(t.newTypeReference))
			addParameter("sourceArgs", object.newArrayTypeReference)
			varArgs = true
			body = [
				'''return delegate.mapOne(type, source, sourceArgs);'''
			]
		]
		annotatedClass.addMethod("mapAll") [
			val t = addTypeParameter("T", object)
			returnType = findTypeGlobally(Iterable).newTypeReference(t.newTypeReference)
			addParameter("sources", findTypeGlobally(Iterable).newTypeReference(newWildcardTypeReference))
			addParameter("sourceArgs", object.newArrayTypeReference)
			varArgs = true
			body = [
				'''return delegate.mapAll(null, sources, sourceArgs);'''
			]
		]
		annotatedClass.addMethod("mapAllAs") [
			val t = addTypeParameter("T", object)
			returnType = findTypeGlobally(Iterable).newTypeReference(t.newTypeReference)
			addParameter("sources", findTypeGlobally(Iterable).newTypeReference(newWildcardTypeReference))
			addParameter("type", findTypeGlobally(Class).newTypeReference(t.newTypeReference))
			addParameter("sourceArgs", object.newArrayTypeReference)
			varArgs = true
			body = [
				'''return delegate.mapAll(type, sources, sourceArgs);'''
			]
		]
	}
}
