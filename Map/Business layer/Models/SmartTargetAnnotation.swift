//
//  SmartTargetAnnotation.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 24.12.2019.
//

import MapKit

final class SmartTargetAnnotation: NSObject, MKAnnotation
{
	let title: String?
	var coordinate: CLLocationCoordinate2D

	init(title: String?, coordinate: CLLocationCoordinate2D) {
		self.title = title
		self.coordinate = coordinate
		super.init()
	}
}
