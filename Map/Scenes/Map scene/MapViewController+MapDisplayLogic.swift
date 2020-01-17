//
//  MapViewController+MapDisplayLogic.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

// MARK: - MapDisplayLogic protocol
protocol MapDisplayLogic: AnyObject
{
	func displayAnnotations(_ viewModel: Map.FetchAnnotations.ViewModel)
	func displaySmartTarget(_ viewModel: Map.GetSmartTarget.ViewModel)
	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel)
	func displayAddress(_ viewModel: Map.Address.ViewModel)

	// Adding, updating, removing smart targets
	func displayAddSmartTarget(_ viewModel: Map.AddSmartTarget.ViewModel)
	func displayRemoveSmartTarget(_ viewModel: Map.RemoveSmartTarget.ViewModel)
	func displayUpdateSmartTarget(_ viewModel: Map.UpdateSmartTarget.ViewModel)

	func displayUpdateAnnotations(_ viewModel: Map.UpdateAnnotations.ViewModel)

	// Notifications
	func displaySetNotificationServiceDelegate(_ viewModel: Map.SetNotificationServiceDelegate.ViewModel)

	// Monitoring Region
	func displayStartMonitoringRegion(_ viewModel: Map.StartMonitoringRegion.ViewModel)
	func displayStopMonitoringRegion(_ viewModel: Map.StopMonitoringRegion.ViewModel)

	// Settings
	func displayGetCurrentRadius(_ viewModel: Map.GetCurrentRadius.ViewModel)
	func displayGetRangeRadius(_ viewModel: Map.GetRangeRadius.ViewModel)
	func displayGetMeasuringSystem(_ viewModel: Map.GetMeasuringSystem.ViewModel)
	func displayGetRemovePinAlertSettings(_ viewModel: Map.GetRemovePinAlertSettings.ViewModel)
}

// MARK: - Map display logic
extension MapViewController: MapDisplayLogic
{
	func displayAnnotations(_ viewModel: Map.FetchAnnotations.ViewModel) {
		mapView.addAnnotations(viewModel.annotations)
		mapView.showAnnotations(mapView.annotations, animated: false)
	}

	func displaySmartTarget(_ viewModel: Map.GetSmartTarget.ViewModel) {
		interactor.temptSmartTarget = viewModel.smartTarget
	}

	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel) {
		if viewModel.isShownUserPosition, mapView.showsUserLocation == false, let coordinate = viewModel.userCoordinate {
			showLocation(coordinate: coordinate)
		}
		mapView.showsUserLocation = viewModel.isShownUserPosition
		currentLocationButton.isHidden = (viewModel.isShownUserPosition == false)
	}

	func displayAddress(_ viewModel: Map.Address.ViewModel) {
		smartTargetMenu?.title = viewModel.address
	}

	func displayAddSmartTarget(_ viewModel: Map.AddSmartTarget.ViewModel) { }

	func displayRemoveSmartTarget(_ viewModel: Map.RemoveSmartTarget.ViewModel) { }

	func displaySetNotificationServiceDelegate(_ viewModel: Map.SetNotificationServiceDelegate.ViewModel) { }

	func displayStartMonitoringRegion(_ viewModel: Map.StartMonitoringRegion.ViewModel) { }

	func displayStopMonitoringRegion(_ viewModel: Map.StopMonitoringRegion.ViewModel) { }

	func displayUpdateSmartTarget(_ viewModel: Map.UpdateSmartTarget.ViewModel) { }

	func displayUpdateAnnotations(_ viewModel: Map.UpdateAnnotations.ViewModel) {
		guard viewModel.needUpdate else { return }
		mapView.removeAnnotations(viewModel.removedAnnotations)
		mapView.addAnnotations(viewModel.addedAnnotations)
	}

	func displayGetCurrentRadius(_ viewModel: Map.GetCurrentRadius.ViewModel) {
		if temptLastPointer == nil {
			circleRadius = viewModel.radius
			smartTargetMenu?.sliderValue = Float(circleRadius)
		}
	}

	func displayGetRangeRadius(_ viewModel: Map.GetRangeRadius.ViewModel) {
		smartTargetMenu?.sliderValuesRange = (viewModel.userValues.lower, viewModel.userValues.upper)
		if
			let menu = smartTargetMenu,
			let smartTarget = interactor.temptSmartTarget,
			temptLastPointer != nil {
			menu.sliderValuesRange = (min(menu.sliderValuesRange.min, circleRadius),
									  max(menu.sliderValuesRange.max, circleRadius))
			menu.sliderValue = Float(smartTarget.radius ?? menu.sliderValuesRange.min)
		}
	}

	func displayGetMeasuringSystem(_ viewModel: Map.GetMeasuringSystem.ViewModel) {
		smartTargetMenu?.sliderFactor = Float(viewModel.measuringFactor)
		smartTargetMenu?.sliderValueMeasuringSymbol = viewModel.measuringSymbol
	}

	func displayGetRemovePinAlertSettings(_ viewModel: Map.GetRemovePinAlertSettings.ViewModel) {
		removePinAlertOn = viewModel.removePinAlertOn
	}
}