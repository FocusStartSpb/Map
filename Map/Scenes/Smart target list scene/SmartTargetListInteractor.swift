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
	func deleteSmartTargets(_ request: SmartTargetList.DeleteSmartTargets.Request)
	func updateSmartTargets(_ request: SmartTargetList.UpdateSmartTargets.Request)
	func updateSmartTarget(_ request: SmartTargetList.UpdateSmartTarget.Request)
	func showEmptyView(_ request: SmartTargetList.ShowEmptyView.Request)
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
	var smartTargetsCount: Int { get }
	var oldSmartTargetCollection: ISmartTargetCollection? { get set }
	var smartTargetCollection: ISmartTargetCollection? { get set }
	var editedSmartTarget: SmartTarget? { get set }
	var didUpdateSmartTargets: Bool { get set }
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
	var didUpdateSmartTargets = false
	var editedSmartTarget: SmartTarget?

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

	func deleteSmartTargets(_ request: SmartTargetList.DeleteSmartTargets.Request) {
		request.smartTargetsIndexSet.forEach { index in
			guard let uuid = self.smartTargetCollection?.smartTargets[Int(index)].uid else { return }
			self.smartTargetCollection?.remove(atUID: uuid)
		}
		saveSmartTargetCollection()
	}

	private func saveSmartTargetCollection() {
		guard let collection = smartTargetCollection as? T.Element else { return }

		worker.saveSmartTargets(collection) { [weak self] result in
			let result = result.map { $0 as? ISmartTargetCollection ?? SmartTargetCollection() }
			let response = SmartTargetList.DeleteSmartTargets.Response(result: result)
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
		if didUpdateSmartTargets == false {
			oldSmartTargetCollection = smartTargetCollection.copy()
			didUpdateSmartTargets = true
		}
	}

	func updateSmartTarget(_ request: SmartTargetList.UpdateSmartTarget.Request) {
		guard let editedSmartTarget = self.editedSmartTarget else { return }
		guard let smartTargetIndex = self.smartTargetCollection?.index(at: editedSmartTarget) else { return }
		let response = SmartTargetList.UpdateSmartTarget.Response(editedSmartTargetIndex: smartTargetIndex)
		self.saveSmartTargetCollection()
		presenter.presentUpdateSmartTarget(response)
	}

	func showEmptyView(_ request: SmartTargetList.ShowEmptyView.Request) {
		let response = SmartTargetList.ShowEmptyView.Response(showEmptyView: (self.smartTargetsCount == 0))
		presenter.presentEmptyView(response)
	}
}

// MARK: - Smart target list data store
extension SmartTargetListInteractor: SmartTargetListDataStore
{
	var smartTargetsCount: Int {
		smartTargetCollection?.count ?? 0
	}
}
