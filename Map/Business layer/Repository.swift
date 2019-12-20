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

// MARK: - Class
final class SmartTargetRepository
{

	// MARK: ...Private properties
	private var decoderService: IDecoderService
	private var dataBaseService: DataBaseService<Element>

	// MARK: ...Initialization
	init(decoderService: IDecoderService, dataBaseService: DataBaseService<Element>) {
		self.decoderService = decoderService
		self.dataBaseService = dataBaseService
	}
}

extension SmartTargetRepository: ISmartTargetRepository
{
	func fetchSmartTargets(
		_ completion: @escaping SmartTargetsResultCompletion) {
	}
}
