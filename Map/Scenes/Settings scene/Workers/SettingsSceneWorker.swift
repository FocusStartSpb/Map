//
//  SettingsSceneWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 31.12.2019.
//

final class SettingsSceneWorker: SettingsWorker
{
	func getMeasuringSystemItems() -> [String] {
		UserPreferences.MeasuringSystem.allCases.map { $0.rawValue }
	}

	func getSortingItems() -> [String] {
		UserPreferences.Sorting.allCases.map { $0.rawValue }
	}

	var minRangeOfRadius: Double {
		UserPreferences.minRangeOfRadius ?? 0
	}

	var minValueOfRadius: Double {
		UserPreferences.minValueOfRadius ?? 0
	}

	var maxValueOfRadius: Double {
		UserPreferences.maxValueOfRadius ?? 0
	}
}
