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
 * This callback is called on the source object after the ITransformerObjectWrapper,
 * but before the target object is created and the transformation method is invoked.
 * The callback can issue a veto here that prevents further processing of the object.
 * This can be used for validation purposes.
 */
interface ITransformerPreProcessor {
	/**
	 * Pre-process the source object(s).
	 * @return true if processing shall continue, false if not.
	 */
	def boolean preProcess(Iterable<Object> source)
}
