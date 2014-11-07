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
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EPackage
import com.google.inject.Inject

@Transformer
class BaseTransformer {
	@Inject ClassifierTransformer ct
	
	@Transform
	def ENamedElement transform(ENamedElement source) {
		target => [
			name = source.name + "Copy"
		]
	}
	
	@Transform
	def EPackage transform(EPackage source) {
		target => [
			EClassifiers += source.EClassifiers.mapAll
		]
	}
}
