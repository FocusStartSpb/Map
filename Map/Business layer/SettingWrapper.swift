//
//  Storage.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import Foundation

@propertyWrapper struct SettingWrapper<Value>
{

	private let userDefaults: UserDefaults = .standard

	let key: String
	var defaultValue: Value?

	var wrappedValue: Value? {
		get {
			userDefaults.value(forKey: key) as? Value ?? defaultValue
		}
		set {
			userDefaults.set(newValue, forKey: key)
		}
	}

	func removeValue() {
		userDefaults.removeObject(forKey: key)
	}
}
