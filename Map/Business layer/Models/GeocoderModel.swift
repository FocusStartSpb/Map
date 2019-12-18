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
	let metaDataProperty: GeoCollectionMetaDataProperty?
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
	let name, description: String?
	let boundedBy: BoundedBy?
	let point: Point?

	enum CodingKeys: String, CodingKey
	{
		case metaDataProperty, name, description
		case boundedBy
		case point = "Point"
	}
}

// MARK: - BoundedBy
struct BoundedBy: Decodable
{
	let envelope: Envelope?

	enum CodingKeys: String, CodingKey
	{
		case envelope = "Envelope"
	}
}

// MARK: - Envelope
struct Envelope: Decodable
{
	let lowerCorner, upperCorner: String?
}

// MARK: - GeoObjectMetaDataProperty
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
	let address: Address?
	let addressDetails: AddressDetails?

	enum CodingKeys: String, CodingKey
	{
		case precision, text, kind
		case address = "Address"
		case addressDetails = "AddressDetails"
	}
}

// MARK: - Address
struct Address: Decodable
{
	let countryCode, formatted, postalCode: String?
	let components: [Component]?

	enum CodingKeys: String, CodingKey
	{
		case countryCode = "country_code"
		case formatted
		case postalCode = "postal_code"
		case components = "Components"
	}
}

// MARK: - Component
struct Component: Decodable
{
	let kind, name: String?
}

// MARK: - AddressDetails
struct AddressDetails: Decodable
{
	let country: Country?

	enum CodingKeys: String, CodingKey
	{
		case country = "Country"
	}
}

// MARK: - Country
struct Country: Decodable
{
	let addressLine, countryNameCode, countryName: String?
	let administrativeArea: AdministrativeArea?

	enum CodingKeys: String, CodingKey
	{
		case addressLine = "AddressLine"
		case countryNameCode = "CountryNameCode"
		case countryName = "CountryName"
		case administrativeArea = "AdministrativeArea"
	}
}

// MARK: - AdministrativeArea
struct AdministrativeArea: Decodable
{
	let administrativeAreaName: String?
	let locality: Locality?

	enum CodingKeys: String, CodingKey
	{
		case administrativeAreaName = "AdministrativeAreaName"
		case locality = "Locality"
	}
}

// MARK: - Locality
struct Locality: Decodable
{
	let localityName: String?
	let thoroughfare: Thoroughfare?
	let dependentLocality: DependentLocality?

	enum CodingKeys: String, CodingKey
	{
		case localityName = "LocalityName"
		case thoroughfare = "Thoroughfare"
		case dependentLocality = "DependentLocality"
	}
}

// MARK: - DependentLocality
struct DependentLocality: Decodable
{
	let dependentLocalityName: String?
	let dependentLocality: SecondDependentLocality?

	enum CodingKeys: String, CodingKey
	{
		case dependentLocalityName = "DependentLocalityName"
		case dependentLocality = "DependentLocality"
	}
}

// MARK: - SecondDependentLocality
struct SecondDependentLocality: Decodable
{
	let dependentLocalityName: String?

	enum CodingKeys: String, CodingKey
	{
		case dependentLocalityName = "DependentLocalityName"
	}
}

// MARK: - Thoroughfare
struct Thoroughfare: Decodable
{
	let thoroughfareName: String?
	let premise: Premise?

	enum CodingKeys: String, CodingKey
	{
		case thoroughfareName = "ThoroughfareName"
		case premise = "Premise"
	}
}

// MARK: - Premise
struct Premise: Decodable
{
	let premiseNumber: String?
	let postalCode: PostalCode?

	enum CodingKeys: String, CodingKey
	{
		case premiseNumber = "PremiseNumber"
		case postalCode = "PostalCode"
	}
}

// MARK: - PostalCode
struct PostalCode: Decodable
{
	let postalCodeNumber: String?

	enum CodingKeys: String, CodingKey
	{
		case postalCodeNumber = "PostalCodeNumber"
	}
}

// MARK: - Point
struct Point: Decodable
{
	let pos: String?
}

// MARK: - GeoObjectCollectionMetaDataProperty
struct GeoCollectionMetaDataProperty: Decodable
{
	let geocoderResponseMetaData: GeocoderResponseMetaData?

	enum CodingKeys: String, CodingKey
	{
		case geocoderResponseMetaData = "GeocoderResponseMetaData"
	}
}

// MARK: - GeocoderResponseMetaData
struct GeocoderResponseMetaData: Decodable
{
	let point: Point?
	let request, results, found: String?

	enum CodingKeys: String, CodingKey
	{
		case point = "Point"
		case request, results, found
	}
}
