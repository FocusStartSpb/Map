//
//  DataBaseWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

final class DataBaseWorker<T: ISmartTargetRepository>
{
	typealias SmartTargetResult = (Result<T.Element, ServiceError>) -> Void

	// MARK: Private methods
	private let repository: T

	// MARK: Initialization
	init(repository: T) {
		self.repository = repository
	}

	// MARK: Methods
	func fetchSmartTargets(_ completion: @escaping SmartTargetResult) {
		repository.loadSmartTargetCollection(completion)
	}

	func saveSmartTargets(_ collection: T.Element, _ completion: @escaping SmartTargetResult) {
		repository.saveSmartTargetCollection(collection, completion)
	}
}
