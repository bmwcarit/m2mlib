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
 *  Callback that is informed when something, anything, goes wrong during transformation.
 */
interface ITransformerErrorHandler {
	def void handleError(Iterable<Object> sources, TransformerErrorCode s, Exception x)
}

enum TransformerErrorCode {
	PRE_PROCESS_FAILED,
	CREATE_INSTANCE_FAILED,
	NO_TRANSFORMER_FOUND,
	UNCAUGHT_EXCEPTION
}
