//
//  SmartTarget.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import CoreLocation

// MARK: - Struct
struct SmartTarget
{

	// MARK: ...Private properties
	private let dateOfCreated: Date

	// MARK: ...Properties
	let uid: String
	var title: String
	let coordinates: CLLocationCoordinate2D
	var address: String?
	var radius: Double?

	private enum CodingKeys: String, CodingKey
	{
		case uid
		case title
		case coordinates
		case dateOfCreated
		case address
	}

	// MARK: ...Initialization
	init(uid: String = UUID().uuidString,
		 title: String,
		 coordinates: CLLocationCoordinate2D,
		 address: String? = nil) {

		self.uid = uid
		self.title = title
		self.coordinates = coordinates
		self.dateOfCreated = Date()
		self.address = address
	}
}

// MARK: - Codable
extension SmartTarget: Codable
{
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		uid = try container.decode(String.self, forKey: .uid)
		title = try container.decode(String.self, forKey: .title)
		coordinates = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)
		dateOfCreated = try container.decode(Date.self, forKey: .dateOfCreated)
		address = try? container.decode(String.self, forKey: .address)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(uid, forKey: .uid)
		try container.encode(title, forKey: .title)
		try container.encode(coordinates, forKey: .coordinates)
		try container.encode(dateOfCreated, forKey: .dateOfCreated)
		try container.encode(address, forKey: .address)
	}
}

// MARK: - Comparable
extension SmartTarget: Comparable
{
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.uid == rhs.uid
	}

	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.dateOfCreated < rhs.dateOfCreated
	}
}

// MARK: - Hashable
extension SmartTarget: Hashable
{
	func hash(into hasher: inout Hasher) {
		hasher.combine(uid)
	}
}

// MARK: - Custom string convertible
extension SmartTarget: CustomStringConvertible
{
	var description: String { "uid: " + uid + ", title: " + title }
}
