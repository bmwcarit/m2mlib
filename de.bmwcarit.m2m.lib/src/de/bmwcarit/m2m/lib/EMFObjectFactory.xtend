/*******************************************************************************
 * Copyright (C) 2014, BMW Car IT GmbH
 * Author: Achim Demelt (achim.demelt@bmw-carit.de)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package de.bmwcarit.m2m.lib

import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EClass

/**
 * A factory to create EMF objects.
 */
class EMFObjectFactory implements ITransformerObjectFactory {
	/**
	 * Creates an EMF object for the given type. The type must be the interface of the object to
	 * create. The EMFObjectFactory checks if any EPackage in the registry is capable of creating
	 * this kind of object. If one is found, an instance is created by its appropriate EFactory.
	 */
	override <T> createInstance(Class<T> type) {
		val eClass = EPackage.Registry.INSTANCE.entrySet.map[
			EPackage.Registry.INSTANCE.getEPackage(key).EClassifiers.findFirst[
				instanceClass == type
			]
		].filter(EClass).head
		if (eClass == null)
			null
		else
			EcoreUtil.create(eClass) as T
	}
}
