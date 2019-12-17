//
//  MapVCExtension.swift
//  Map
//
//  Created by Ekaterina Khudzhamkulova on 17.12.2019.
//

import Foundation
import MapKit

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let latestLocation = locations.first else { return }

		if self.currentCoordinate == nil {
			self.zoomToLatestLocation(with: latestLocation.coordinate)
		}
		self.currentCoordinate = latestLocation.coordinate
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			beginLocationUpdates(locationManager: manager)
		}
	}
}
