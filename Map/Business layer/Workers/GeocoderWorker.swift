//
//  GeocoderWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 25.12.2019.
//

import Foundation

typealias GeoDataWrapperCompletion = (GeoResults) -> Void

final class GeocoderWorker<T: IDecoderGeocoder>
{
	// MARK: Private methods
	private let decoder: T
	private let service: IGeocoderServiceProtocol

	// MARK: Initialization
	init(service: IGeocoderServiceProtocol, decoder: T) {
		self.service = service
		self.decoder = decoder
	}

	// MARK: Methods
	func getGeocoderMetaData(by geocode: GeocoderService.Geocode, _ completion: @escaping GeoDataWrapperCompletion) {
		service.getGeoData(by: geocode) { [weak self] result in
			switch result {
			case .success(let data):
				self?.decoder.decodeGeocode(data, completion: completion)
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
