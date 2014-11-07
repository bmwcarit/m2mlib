/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib.test.simple

import de.bmwcarit.m2m.lib.annotations.Transform
import de.bmwcarit.m2m.lib.annotations.Transformer
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage

@Transformer
class SimpleTransformerWithMultipleArguments {
	@Transform
	def EPackage transform(EPackage source) {
		target => [
			name = source.name + "Copy"
			EClassifiers += source.EClassifiers.mapAll(0 as Integer)
			EClassifiers += source.EClassifiers.mapAll(1 as Integer)
		]
	}
	
	@Transform
	def EClass transform(EClass source, Integer i) {
		target => [
			name = source.name + "Copy" + i
		]
	}
}
