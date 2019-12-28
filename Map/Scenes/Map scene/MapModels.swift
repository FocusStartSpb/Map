//
//  MapModels.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//
// swiftlint:disable nesting

import CoreLocation

enum MapDisplayLogicError: Error
{
	case cannotGetAddress(message: String)
}

typealias GeocoderResponseResult = Result<GeoDataWrapper, ServiceError>
typealias AddressViewModelResult = Result<String, MapDisplayLogicError>

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
		}

		struct ViewModel
		{
			let result: AddressViewModelResult
		}
	}
}
