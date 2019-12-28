//
//  SmartTargetListInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListBusinessLogic protocol
protocol SmartTargetListBusinessLogic
{
	func loadSmartTargets(_ request: SmartTargetList.LoadSmartTargets.Request)
	func saveSmartTargets(_ request: SmartTargetList.SaveSmartTargets.Request)
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
	var smartTargetsCount: Int { get }

	func getSmartTarget(by index: Int) -> SmartTarget?
}

// MARK: - Class
final class SmartTargetListInteractor<T: ISmartTargetRepository>
{
	// MARK: ...Private properties
	private var presenter: SmartTargetListPresentationLogic
	private var worker: DataBaseWorker<T>

	//var collection: T.Element?
	private(set) var smartTargetCollection: ISmartTargetCollection?

	// MARK: ...Initialization
	init(presenter: SmartTargetListPresentationLogic, worker: DataBaseWorker<T>) {
		self.presenter = presenter
		self.worker = worker
	}
}

// MARK: - Smart target list business logic
extension SmartTargetListInteractor: SmartTargetListBusinessLogic
{
	func loadSmartTargets(_ request: SmartTargetList.LoadSmartTargets.Request) {

		worker.fetchSmartTargets { [weak self] result in
			if case .success(let collection) = result {
				self?.smartTargetCollection = collection
			}
			let response = SmartTargetList.LoadSmartTargets.Response(result: result)
			self?.presenter.presentLoadSmartTargets(response)
		}
	}

	func saveSmartTargets(_ request: SmartTargetList.SaveSmartTargets.Request) {
		self.smartTargetCollection = request.request
		guard let collection = smartTargetCollection as? T.Element else { return }

		worker.saveSmartTargets(collection) { [weak self] result in
			let response = SmartTargetList.SaveSmartTargets.Response(result: result)
			self?.presenter.presentSaveSmartTargets(response)
		}
	}
}

// MARK: - Smart target list data store
extension SmartTargetListInteractor: SmartTargetListDataStore
{
	var smartTargetsCount: Int {
		smartTargetCollection?.count ?? 0
	}

	func getSmartTarget(by index: Int) -> SmartTarget? {
		self.smartTargetCollection?.smartTargets[index]
	}
}
