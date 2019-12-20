//
//  DecoderService.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import Foundation

typealias SmartTargetsResult = Result<ISmartTargetCollection, ServiceError>

typealias SmartTargetsResultCompletion = (SmartTargetsResult) -> Void

protocol IDecoderService
{
	func decodeSmartTargets(_ data: Data,
							_ completion: @escaping SmartTargetsResultCompletion)
}
protocol IDecoderGeocoder
{
	func decodeGeocode(_ data: Data, completion: @escaping (GeoResults) -> Void)
}

final class DecoderService
{
}

extension DecoderService: IDecoderService
{
	func decodeSmartTargets(_ data: Data, _ completion: @escaping SmartTargetsResultCompletion) {
	}
}
extension DecoderService: IDecoderGeocoder
{
	func decodeGeocode(_ data: Data, completion: @escaping (GeoResults) -> Void) {
		do {
			let result = try JSONDecoder().decode(GeoDataWrapper.self, from: data)
			completion(.success(result))
		}
		catch {
			completion(.failure(.decoding(error)))
		}
	}
}
