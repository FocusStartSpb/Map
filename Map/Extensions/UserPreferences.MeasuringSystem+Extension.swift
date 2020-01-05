//
//  UserPreferences.MeasuringSystem+Extension.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 01.01.2020.
//

extension UserPreferences.MeasuringSystem
{
	var symbol: String {
		switch self {
		case .mile: return "ft"
		case .kilometer: return "m"
		}
	}

	var factor: Double {
		switch self {
		case .mile: return 3.280_839_895_013_1
		case .kilometer: return 1
		}
	}
}
