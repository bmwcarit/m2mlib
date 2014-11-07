/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib

/**
 * Defines the behavior that is injected by the @Transformer active annotation.
 */
interface ITransformer {
	def <T> T map(Object source, Object... sourceArgs)

	def <T> T mapAs(Object source, Class<T> type, Object... sourceArgs)

	def <T> Iterable<T> mapAll(Iterable<?> sources, Object... sourceArgs)

	def <T> Iterable<T> mapAllAs(Iterable<?> sources, Class<T> type, Object... sourceArgs)

	def TransformerDelegate getTransformerDelegate()
}
