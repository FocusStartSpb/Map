//
//  Constants.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import CoreLocation
import UIKit

enum Constants
{
	static let maxLenghtOfTitle = 30

	enum MeasurementSystem
	{
		// swiftlint:disable:next nesting
		enum Symbol
		{
			static let imperial = "фт"
			static let metric = "м"
		}
	}

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

	enum Generator
	{
		static let impactFeedbackGenerator: UIImpactFeedbackGenerator = {
			if #available(iOS 13.0, *) {
				return UIImpactFeedbackGenerator(style: .soft)
			}
			else {
				return UIImpactFeedbackGenerator(style: .light)
			}
		}()
	}

	enum DetailScreenColors
	{
		static let colorForSliderAndEditableAddresView: UIColor = {
			if #available(iOS 13.0, *) {
				return .systemGray
			}
			else {
				return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
			}
		}()
	}
}
