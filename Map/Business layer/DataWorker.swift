//
//  DataWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

final class DataWorker<T: ISmartTargetRepository>
{
	// MARK: Private methods
	private var repository: T

	// MARK: Initialization
	init(repository: T) {
		self.repository = repository
	}

	// MARK: Methods
	func fetchSmartTargets(_ completion: @escaping SmartTargetsResultCompletion) {
		repository.loadSmartTargetCollection(completion)
	}
}
