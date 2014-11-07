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
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcorePackage

@Transformer
class SimpleTransformerWithCommonTransform {
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
			target
	}
	
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
