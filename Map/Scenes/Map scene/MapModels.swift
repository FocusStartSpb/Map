//
//  MapModels.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//
import CoreLocation
// swiftlint:disable nesting
enum Map
{
	// MARK: Use cases

	// MARK: ...SmartTargets
	enum SmartTargets
	{
		struct Request
		{
		}

		struct Response
		{
			let smartTargets: [SmartTarget]
		}

		struct ViewModel
		{
			let smartTargets: [SmartTarget]
		}
	}

//	enum UpdateLocation
//	{
//		struct Request
//		{
//			let locations: [CLLocation]
//		}
//
//		struct Response
//		{
//			let coordinate: CLLocationCoordinate2D
//		}
//
//		struct ViewModel
//		{
//			let coordinate: CLLocationCoordinate2D
//		}
//	}
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
}
