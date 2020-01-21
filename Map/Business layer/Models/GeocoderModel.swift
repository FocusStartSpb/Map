//
//  GeocoderModel.swift
//  Map
//
//  Created by Антон on 17.12.2019.
//
import Foundation

// MARK: - GeoDataWrapper
struct GeoDataWrapper: Decodable
{
	let response: Response?
}

// MARK: - Response
struct Response: Decodable
{
	let geoCollection: GeoCollection?

	enum CodingKeys: String, CodingKey
	{
		case geoCollection = "GeoObjectCollection"
	}
}

// MARK: - GeoCollection
struct GeoCollection: Decodable
{
	let featureMember: [FeatureMember]?
}

// MARK: - FeatureMember
struct FeatureMember: Decodable
{
	let geo: Geo?

	enum CodingKeys: String, CodingKey
	{
		case geo = "GeoObject"
	}
}

// MARK: - Geo
struct Geo: Decodable
{
	let metaDataProperty: GeoMetaDataProperty?
}

// MARK: - GeoMetaDataProperty
struct GeoMetaDataProperty: Decodable
{
	let geocoderMetaData: GeocoderMetaData?

	enum CodingKeys: String, CodingKey
	{
		case geocoderMetaData = "GeocoderMetaData"
	}
}

// MARK: - GeocoderMetaData
struct GeocoderMetaData: Decodable
{
	let precision, text, kind: String?

	enum CodingKeys: String, CodingKey
	{
		case precision, text, kind
	}
}
