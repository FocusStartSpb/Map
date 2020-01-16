//
//  Constants.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import CoreLocation
import CoreGraphics

enum Constants
{

	static let maxLenghtOfTitle = 30

	enum Radius
	{
		static let defaultValue: CLLocationDistance = 300
		static let defaultMinimumValue: CLLocationDistance = 100
		static let defaultMaximumValue: CLLocationDistance = 5_000
		static let defaultMinimumRange: CLLocationDistance = 700
		static let defaultLowerValue: CLLocationDistance = 300
		static let defaultUpperValue: CLLocationDistance = 1_000
	}

	enum Distance
	{
		static let latitudalMeters: CLLocationDistance = 5_000
		static let longtitudalMeters: CLLocationDistance = 5_000
	}

	enum Size
	{
		static let mapButton: CGFloat = 40
	}

	enum Offset
	{
		static let mapButton: CGFloat = 20
	}
}
