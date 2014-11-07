/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib.annotations

import de.bmwcarit.m2m.lib.EMFObjectFactory
import de.bmwcarit.m2m.lib.ITransformerErrorHandler
import de.bmwcarit.m2m.lib.ITransformerObjectFactory
import de.bmwcarit.m2m.lib.ITransformerObjectWrapper
import de.bmwcarit.m2m.lib.ITransformerPostProcessor
import de.bmwcarit.m2m.lib.ITransformerPreProcessor
import de.bmwcarit.m2m.lib.internal.TransformerProcessor
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import de.bmwcarit.m2m.lib.ITransformer

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Active(TransformerProcessor)
annotation Transformer {
	Class<? extends ITransformerObjectFactory> factory = typeof(EMFObjectFactory)
	Class<? extends ITransformer>[] uses = #[]
	Class<? extends ITransformerObjectWrapper> objectWrapper = typeof(ITransformerObjectWrapper) 
	Class<? extends ITransformerPreProcessor> preProcessor = typeof(ITransformerPreProcessor)
	Class<? extends ITransformerPostProcessor> postProcessor = typeof(ITransformerPostProcessor)
	Class<? extends ITransformerErrorHandler> errorHandler = typeof(ITransformerErrorHandler)
}
