//
//  GeocoderService.swift
//  Map
//
//  Created by Антон on 17.12.2019.
//

import Foundation
protocol IGeocoderServiceProtocol
{
	func getGeoObjectByCoordinates(latitude: Double, logitude: Double, callBack: @escaping (GeoObjectResults) -> Void)
}

final class GeocoderService
{
	private let apiKey = "2be7b489-cc26-414c-85dc-6e189996e226"
	private let basicURL = "https://geocode-maps.yandex.ru/1.x/"

	private func createGeocode(_ logitude: String, _ latitude: String) -> String {
		return logitude + "," + latitude
	}
	private func createURL(latitude: String, logitude: String) -> URL? {
		var url: URL? {
			guard var urlComponents = URLComponents(string: basicURL) else { return nil }
			urlComponents.queryItems = [
				URLQueryItem(name: "apikey", value: apiKey),
				URLQueryItem(name: "geocode", value: createGeocode(logitude, latitude)),
				URLQueryItem(name: "format", value: "json"),
			]
			return urlComponents.url
		}
		return url
	}
}
extension GeocoderService: IGeocoderServiceProtocol
{
	func getGeoObjectByCoordinates(latitude: Double, logitude: Double, callBack: @escaping (GeoObjectResults) -> Void) {
		let latitudeString = latitude.description
		let logitudeString = logitude.description
		guard let url = createURL(latitude: latitudeString, logitude: logitudeString) else {
			callBack(.failure(.wrongURL))
			return
		}
		let urlRequest = URLRequest(url: url)
		URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
			if let error = error {
				callBack(.failure(.session(error)))
			}
			guard let response = response as? HTTPURLResponse else {
				callBack(.failure(.noHTTPResponse))
				return
			}
			switch response.statusCode {
			case 400..<500:
				callBack(.failure(.clientError))
			case 500..<600:
				callBack(.failure(.serverError))
			default:
				break
			}
			if let data = data {
				do {
					let object = try JSONDecoder().decode(GeoObjects.self, from: data)
					callBack(.success(object))
				}
				catch {
					callBack(.failure(.decodingError(error)))
				}
			}
			else {
				callBack(.failure(.noData))
			}
		})
		.resume()
	}
}
