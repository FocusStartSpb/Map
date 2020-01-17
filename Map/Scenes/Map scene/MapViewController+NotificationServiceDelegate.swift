//
//  MapViewController+NotificationServiceDelegate.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import Foundation

extension MapViewController: NotificationServiceDelegate
{
	func notificationService(_ notificationService: NotificationService,
							 action: NotificationService.Action,
							 forUID uid: String,
							 atNotificationDeliveryDate deliveryDate: Date) {
		switch action {
		case .show:
			guard let annotation = annotations.first(where: { $0.uid == uid }) else { return }
			showLocation(coordinate: annotation.coordinate)
			mapView.selectAnnotation(annotation, animated: true)
		case .dismiss: break
		case .cancel: break
		case .default: break
		}
	}

	func notificationService(_ notificationService: NotificationService,
							 didReceiveNotificationForUID uid: String,
							 atNotificationDeliveryDate deliveryDate: Date) {
	}
}
