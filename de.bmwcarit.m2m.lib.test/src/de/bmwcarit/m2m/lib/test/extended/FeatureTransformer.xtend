/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib.test.extended

import de.bmwcarit.m2m.lib.annotations.Transform
import de.bmwcarit.m2m.lib.annotations.Transformer
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EReference
import com.google.inject.Inject

@Transformer
class FeatureTransformer {
	@Inject BaseTransformer bt
	@Inject ClassifierTransformer ct
	
	@Transform
	def EAttribute transform(EAttribute source) {
		target => [
			EType = source.EType.map
		]
	}
	
	@Transform
	def EReference transform(EReference source) {
		target => [
			EType = source.EType.map
		]
	}
}
