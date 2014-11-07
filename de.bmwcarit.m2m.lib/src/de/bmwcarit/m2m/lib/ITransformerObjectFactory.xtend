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
 * Responsible for creating a target object of a given type.
 */
interface ITransformerObjectFactory {
	/**
	 * Create a new instance for the given type.
	 */
	def <T> T createInstance(Class<T> type)
}
