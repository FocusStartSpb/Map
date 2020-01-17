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
	enum FetchAnnotations
	{
		struct Request { }

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

	// MARK: ...AddSmartTarget
	enum AddSmartTarget
	{
		struct Request
		{
			let smartTarget: SmartTarget
		}

		struct Response
		{
			let isAdded: Bool
		}

		struct ViewModel
		{
			let isAdded: Bool
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

	// MARK: ...UpdateSmartTarget
	enum UpdateSmartTarget
	{
		struct Request
		{
			let smartTarget: SmartTarget
		}

		struct Response
		{
			let isUpdated: Bool
		}

		struct ViewModel
		{
			let isUpdated: Bool
		}
	}

	// MARK: ...UpdateAnnotations
	enum UpdateAnnotations
	{
		struct Request
		{
			let annotations: [SmartTargetAnnotation]
		}

		struct Response
		{
			let annotations: [SmartTargetAnnotation]
			let collection: ISmartTargetCollection
			let difference: Difference
		}

		struct ViewModel
		{
			let needUpdate: Bool
			let removedAnnotations: [SmartTargetAnnotation]
			let addedAnnotations: [SmartTargetAnnotation]
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

	// MARK: ...GetMeasurementSystem
	enum GetMeasurementSystem
	{
		struct Request { }

		struct Response
		{
			let measurementSystem: UserPreferences.MeasurementSystem
		}

		struct ViewModel
		{
			let measurementSymbol: String
			let measurementFactor: Double
		}
	}

	// MARK: ...GetRemovePinAlertSettings
	enum GetRemovePinAlertSettings
	{
		struct Request { }

		struct Response
		{
			let removePinAlertOn: Bool
		}

		struct ViewModel
		{
			let removePinAlertOn: Bool
		}
	}

	// MARK: - Notifications

	// MARK: ...SetNotificationServiceDelegate
	enum SetNotificationServiceDelegate
	{
		struct Request
		{
			weak var notificationDelegate: NotificationServiceDelegate?
		}

		struct Response
		{
			let isSet: Bool
		}

		struct ViewModel
		{
			let isSet: Bool
		}
	}

	// Monitoring region

	// MARK: ...StartMonitoringRegion
	enum StartMonitoringRegion
	{
		struct Request
		{
			let smartTarget: SmartTarget
		}

		struct Response
		{
			let isStarted: Bool
		}

		struct ViewModel
		{
			let isStarted: Bool
		}
	}

	// MARK: ...StopMonitoringRegion
	enum StopMonitoringRegion
	{
		struct Request
		{
			let uid: String
		}

		struct Response
		{
			let isStoped: Bool
		}

		struct ViewModel
		{
			let isStoped: Bool
		}
	}
}
