/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib.test.extended

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Test

import static org.junit.Assert.*
import com.google.inject.util.Modules
import com.google.inject.Guice

class ExtendedTransformerTest {
	extension EcoreFactory = EcoreFactory.eINSTANCE
	
	@Test
	def testExtendedTransformer() {
		val transformed = Guice.createInjector(Modules.EMPTY_MODULE).getInstance(BaseTransformer).map(buildModel)

		transformed.check
	}

	def protected check(EPackage transformed) {
		assertTrue(transformed instanceof EPackage)
		val o = transformed as EPackage
		assertEquals("PCopy", o.name)
		assertEquals(2, o.EClassifiers.size)
		val c1 = o.EClassifiers.get(0)
		assertEquals("C1Copy", c1.name)
		assertTrue(c1 instanceof EClass)
		assertEquals(1, (c1 as EClass).EStructuralFeatures.size)
		val a = (c1 as EClass).EStructuralFeatures.get(0)
		assertEquals("ACopy", a.name)
		assertSame(EcorePackage.eINSTANCE.EInt, a.EType)
		val c2 = o.EClassifiers.get(1)
		assertEquals("C2Copy", c2.name)
		assertEquals(1, (c2 as EClass).EStructuralFeatures.size)
		val r = (c2 as EClass).EStructuralFeatures.get(0)
		assertEquals("RCopy", r.name)
		assertSame(c1, r.EType)
	}
	
	def protected buildModel() {
		createEPackage => [
			name = "P"
			val c1 = createEClass => [
				name = "C1"
				EStructuralFeatures += createEAttribute => [
					name = "A"
					EType = EcorePackage.eINSTANCE.EInt
				]
			]
			EClassifiers += c1
			EClassifiers += createEClass => [
				name = "C2"
				EStructuralFeatures += createEReference => [
					name = "R"
					EType = c1
				]
			]
		]
	}
}
