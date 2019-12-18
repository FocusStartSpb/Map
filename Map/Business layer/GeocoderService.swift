//
//  GeocoderService.swift
//  Map
//
//  Created by Антон on 17.12.2019.
//

import Foundation

typealias GeoResults = Result<GeoDataWrapper, ServiceError>
typealias DataResult = Result<Data, ServiceError>

protocol IGeocoderServiceProtocol
{
	func getGeoData(by geocode: GeocoderService.Geocode, _ callBack: @escaping (DataResult) -> Void)
}

final class GeocoderService
{
	struct Geocode
	{
		let longitude: Double
		let latitude: Double
		var description: String {
			longitude.description + "," + latitude.description
		}
	}
	private enum KeyAndUrl
	{
		static let apiKey = "2be7b489-cc26-414c-85dc-6e189996e226"
		static let basicURL = "https://geocode-maps.yandex.ru/1.x/"
	}

	private func createURL(from geocode: String) -> URL? {
		var url: URL? {
			guard var urlComponents = URLComponents(string: KeyAndUrl.basicURL) else { return nil }
			urlComponents.queryItems = [
				URLQueryItem(name: "apikey", value: KeyAndUrl.apiKey),
				URLQueryItem(name: "geocode", value: geocode),
				URLQueryItem(name: "format", value: "json"),
			]
			return urlComponents.url
		}
		return url
	}
}
extension GeocoderService: IGeocoderServiceProtocol
{
	func getGeoData(by geocode: GeocoderService.Geocode, _ callBack: @escaping (DataResult) -> Void) {
		let geocode = geocode.description
		guard let url = createURL(from: geocode) else {
			callBack(.failure(.wrongURL))
			return
		}
		let urlRequest = URLRequest(url: url)
		URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
			if let error = error {
				callBack(.failure(.session(error)))
				return
			}
			guard let response = response as? HTTPURLResponse else {
				callBack(.failure(.noHTTPResponse))
				return
			}
			switch response.statusCode {
			case 400..<500:
				callBack(.failure(.clientError))
				return
			case 500..<600:
				callBack(.failure(.serverError))
				return
			default:
				break
			}
			if let data = data {
				callBack(.success(data))
			}
			else {
				callBack(.failure(.noData))
				return
			}
		})
		.resume()
	}
}
