//
//  Repository.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

protocol ISmartTargetRepository
{
	func fetchSmartTargets(
		_ completion: @escaping SmartTargetsResultCompletion)
}

final class SmartTargetRepository
{
	// MARK: Private methods
	private var decoderService: IDecoderService

	// MARK: Initialization
	init(decoderService: IDecoderService) {
		self.decoderService = decoderService
	}
}

extension SmartTargetRepository: ISmartTargetRepository
{
	func fetchSmartTargets(
		_ completion: @escaping SmartTargetsResultCompletion) {
	}
}
