//
//  SettingsWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

// swiftlint:disable:next required_final
class SettingsWorker
{
	var measurementSystem: UserPreferences.MeasurementSystem? {
		get { UserPreferences.measurementSystem }
		set { UserPreferences.measurementSystem = newValue }
	}

	var sorting: UserPreferences.Sorting? {
		get { UserPreferences.sorting }
		set { UserPreferences.sorting = newValue }
	}

	var forceRemovePin: Bool? {
		get { UserPreferences.forceRemovePin }
		set { UserPreferences.forceRemovePin = newValue }
	}

	var lowerValueOfRadius: Double? {
		get { UserPreferences.lowerValueOfRadius }
		set { UserPreferences.lowerValueOfRadius = newValue }
	}

	var upperValueOfRadius: Double? {
		get { UserPreferences.upperValueOfRadius }
		set { UserPreferences.upperValueOfRadius = newValue }
	}
}
