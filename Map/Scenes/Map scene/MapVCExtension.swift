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
			zoomToLatestLocation(with: latestLocation.coordinate)
		}
		self.currentCoordinate = latestLocation.coordinate
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			beginLocationUpdates(locationManager: manager)
		}
	}

	private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
		let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.latitudinalMeters,
											longitudinalMeters: self.longtitudalMeters)
		self.mapView.setRegion(zoomRegion, animated: true)
	}
}
