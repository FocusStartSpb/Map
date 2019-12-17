//
//  DecoderService.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import Foundation

enum ServiceError: Error
{
	case decodingError(Error)
}

typealias SmartTargetsResult = Result<[SmartTarget], ServiceError>

typealias SmartTargetsResultCompletion = (SmartTargetsResult) -> Void

protocol IDecoderService
{
	func decodeSmartTargets(_ data: Data,
							_ completion: @escaping SmartTargetsResultCompletion)
}

final class DecoderService
{
}

extension DecoderService: IDecoderService
{
	func decodeSmartTargets(_ data: Data, _ completion: @escaping SmartTargetsResultCompletion) {
	}
}
