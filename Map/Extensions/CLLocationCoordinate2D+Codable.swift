//
//  CLLocationCoordinate2D+Codable.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 20.12.2019.
//

import CoreLocation

extension CLLocationCoordinate2D: Codable
{
	enum CodingKeys: String, CodingKey
	{
		case latitude
		case longitude
	}
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init()
		latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
		longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(latitude, forKey: .latitude)
		try container.encode(longitude, forKey: .longitude)
	}
}
