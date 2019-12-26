//
//  SmartTargetListInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListBusinessLogic protocol
protocol SmartTargetListBusinessLogic
{
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
}

// MARK: - Class
final class SmartTargetListInteractor<T: ISmartTargetRepository>
{
	// MARK: ...Private properties
	private var presenter: SmartTargetListPresentationLogic
	private var worker: DataBaseWorker<T>

	// MARK: ...Initialization
	init(presenter: SmartTargetListPresentationLogic, worker: DataBaseWorker<T>) {
		self.presenter = presenter
		self.worker = worker
	}
}

// MARK: - Smart target list business logic
extension SmartTargetListInteractor: SmartTargetListBusinessLogic
{

		worker.fetchSmartTargets { [weak self] result in
			switch result {
			case .success(let targets):
				let response = SmartTargetList.SmartTargets.Response(smartTargetCollection: targets)
				self?.presenter.presentSmartTargets(response: response)
			case .failure(let error):
				print(error)
			}
		}
	}
}

// MARK: - Smart target list data store
extension SmartTargetListInteractor: SmartTargetListDataStore
{
}
