/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib.test.extended

import com.google.inject.Inject
import de.bmwcarit.m2m.lib.annotations.Transform
import de.bmwcarit.m2m.lib.annotations.Transformer
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage

@Transformer
class ClassifierTransformer {
	@Inject BaseTransformer bt
	@Inject FeatureTransformer ft
	
	@Transform
	def EClass transform(EClass source) {
		target => [
			EStructuralFeatures += source.EStructuralFeatures.mapAll
		]
	}

	@Transform
	def EDataType transform(EDataType source) {
		if (source.EPackage == EcorePackage.eINSTANCE)
			source
		else
			target => [
			]
	}
}
