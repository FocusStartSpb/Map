//
//  SmartTargetListInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListBusinessLogic protocol
protocol SmartTargetListBusinessLogic
{
	func doSmartTargets(request: SmartTargetList.SmartTargets.Request)
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
	//var something: Type { get set }
}

// MARK: - Class
final class SmartTargetListInteractor
{
	// MARK: ...Private properties
	private var presenter: SmartTargetListPresentationLogic
	private var worker: DataBaseWorker

	// MARK: ...Initialization
	init(presenter: SmartTargetListPresentationLogic, worker: DataBaseWorker) {
		self.presenter = presenter
		self.worker = worker
	}
}

// MARK: - Smart target list business logic
extension SmartTargetListInteractor: SmartTargetListBusinessLogic
{
	func doSmartTargets(request: SmartTargetList.SmartTargets.Request) {

		worker.fetchSmartTargets { [weak self] result in
			switch result {
			case .success(let targets):
				let response = SmartTargetList.SmartTargets.Response(smartTargets: targets)
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
