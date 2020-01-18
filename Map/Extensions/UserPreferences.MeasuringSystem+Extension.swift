//
//  UserPreferences.MeasurementSystem+Extension.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 01.01.2020.
//

extension UserPreferences.MeasurementSystem
{
	var symbol: String {
		switch self {
		case .imperial: return Constants.MeasurementSystem.Symbol.imperial
		case .metric: return Constants.MeasurementSystem.Symbol.metric
		}
	}

	var factor: Double {
		switch self {
		case .imperial: return 3.280_839_895_013_1
		case .metric: return 1
		}
	}
}
