//
//  MapModels.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//
// swiftlint:disable nesting

import CoreLocation

typealias GeocoderResponseResult = Result<GeoDataWrapper, ServiceError>

enum Map
{
	// MARK: Use cases

	// MARK: ...FetchSmartTargets
	enum FetchSmartTargets
	{
		struct Request
		{
		}

		struct Response
		{
			let smartTargetCollection: ISmartTargetCollection
		}

		struct ViewModel
		{
			let annotations: [SmartTargetAnnotation]
		}
	}

	// MARK: ...GetSmartTarget
	enum GetSmartTarget
	{
		struct Request
		{
			let uid: String
		}

		struct Response
		{
			let smartTarget: SmartTarget
		}

		struct ViewModel
		{
			let smartTarget: SmartTarget
		}
	}

	// MARK: ...SaveSmartTarget
	enum SaveSmartTarget
	{
		struct Request
		{
			let smartTarget: SmartTarget
		}

		struct Response
		{
			let isSaved: Bool
		}

		struct ViewModel
		{
			let isSaved: Bool
		}
	}

	// MARK: ...RemoveSmartTarget
	enum RemoveSmartTarget
	{
		struct Request
		{
			let uid: String
		}

		struct Response
		{
			let isRemoved: Bool
		}

		struct ViewModel
		{
			let isRemoved: Bool
		}
	}

	// MARK: ...UpdateStatus
	enum UpdateStatus
	{
		struct Request {}

		struct Response
		{
			let accessToLocationApproved: Bool
			let userCoordinate: CLLocationCoordinate2D?
		}

		struct ViewModel
		{
			let isShownUserPosition: Bool
			let userCoordinate: CLLocationCoordinate2D?
		}
	}

	// MARK: ...Address
	enum Address
	{
		struct Request
		{
			let coordinate: CLLocationCoordinate2D
		}

		struct Response
		{
			let result: GeocoderResponseResult
			let coordinate: CLLocationCoordinate2D
		}

		struct ViewModel
		{
			let address: String
		}
	}

	// MARK: - Settings

	// MARK: ...GetCurrentRadius
	enum GetCurrentRadius
	{
		struct Request
		{
			let currentRadius: Double
		}

		struct Response
		{
			let currentRadius: Double
			let userValues: (lower: Double, upper: Double)
		}

		struct ViewModel
		{
			let radius: Double
		}
	}

	// MARK: ...GetRangeRadius
	enum GetRangeRadius
	{
		struct Request { }

		struct Response
		{
			let userValues: (lower: Double, upper: Double)
		}

		struct ViewModel
		{
			let userValues: (lower: Double, upper: Double)
		}
	}

	// MARK: ...GetMeasuringSystem
	enum GetMeasuringSystem
	{
		struct Request { }

		struct Response
		{
			let measuringSystem: UserPreferences.MeasuringSystem
		}

		struct ViewModel
		{
			let measuringSymbol: String
			let measuringFactor: Double
		}
	}
}
