//
//  SmartTargetAnnotation.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 24.12.2019.
//

import MapKit

final class SmartTargetAnnotation: NSObject, MKAnnotation
{
	static let identifier = "PinIdentifier"

	let uid: String
	var title: String?
	var coordinate: CLLocationCoordinate2D

	init(uid: String, title: String?, coordinate: CLLocationCoordinate2D) {
		self.uid = uid
		self.title = title
		self.coordinate = coordinate
		super.init()
	}

	func copy() -> Self {
		Self(uid: uid, title: title, coordinate: coordinate)
	}
}
