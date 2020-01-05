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
	func updateSmartTargets(_ request: SmartTargetList.UpdateSmartTargets.Request)
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
	var smartTargetsCount: Int { get }

	func getSmartTarget(at index: Int) -> SmartTarget?

	var oldSmartTargetCollection: ISmartTargetCollection? { get set }
	var smartTargetCollection: ISmartTargetCollection? { get set }
}

// MARK: - Class
final class SmartTargetListInteractor<T: ISmartTargetRepository>
{
	// MARK: ...Private properties
	private var presenter: SmartTargetListPresentationLogic
	private var worker: DataBaseWorker<T>

	// MARK: ...Map data store
	var oldSmartTargetCollection: ISmartTargetCollection?
	var smartTargetCollection: ISmartTargetCollection?

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
				self?.smartTargetCollection = collection as? ISmartTargetCollection
				self?.oldSmartTargetCollection = self?.smartTargetCollection?.copy()
			}
			let result = result.map { $0 as? ISmartTargetCollection ?? SmartTargetCollection() }
			let response = SmartTargetList.LoadSmartTargets.Response(result: result)
			self?.presenter.presentLoadSmartTargets(response)
		}
	}

	func saveSmartTargets(_ request: SmartTargetList.SaveSmartTargets.Request) {
		self.smartTargetCollection = request.smartTargetCollection
		guard let collection = smartTargetCollection as? T.Element else { return }

		worker.saveSmartTargets(collection) { [weak self] result in
			let result = result.map { $0 as? ISmartTargetCollection ?? SmartTargetCollection() }
			let response = SmartTargetList.SaveSmartTargets.Response(result: result)
			self?.presenter.presentSaveSmartTargets(response)
		}
	}

	func updateSmartTargets(_ request: SmartTargetList.UpdateSmartTargets.Request) {
		guard
			let oldCollection = oldSmartTargetCollection?.copy(),
			let smartTargetCollection = smartTargetCollection else { return }

		let differences = smartTargetCollection.smartTargetsOfDifference(from: oldCollection)
		let response = SmartTargetList.UpdateSmartTargets.Response(collection: oldCollection,
																   addedSmartTargets: differences.added,
																   removedSmartTargets: differences.removed,
																   updatedSmartTargets: differences.updated)
		presenter.presentUpdateSmartTargets(response)

		oldSmartTargetCollection = smartTargetCollection.copy()
	}
}

// MARK: - Smart target list data store
extension SmartTargetListInteractor: SmartTargetListDataStore
{
	var smartTargetsCount: Int {
		smartTargetCollection?.count ?? 0
	}

	func getSmartTarget(at index: Int) -> SmartTarget? {
		self.smartTargetCollection?.smartTargets[index]
	}
}
