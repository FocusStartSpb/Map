//
//  DataBaseWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

final class DataBaseWorker
{
	// MARK: Private methods
	private var repository: ISmartTargetRepository

	// MARK: Initialization
	init(repository: ISmartTargetRepository) {
		self.repository = repository
	}

	// MARK: Methods
	func fetchSmartTargets(_ completion: @escaping SmartTargetsResultCompletion) {
		repository.fetchSmartTargets(completion)
	}
}
