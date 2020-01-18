//
//  SmartTargetListInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListBusinessLogic protocol
protocol SmartTargetListBusinessLogic
{
	func deleteSmartTargets(_ request: SmartTargetList.DeleteSmartTargets.Request)
	func updateSmartTargets(_ request: SmartTargetList.UpdateSmartTargets.Request)
	func updateSmartTarget(_ request: SmartTargetList.UpdateSmartTarget.Request)
	func showEmptyView(_ request: SmartTargetList.ShowEmptyView.Request)
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
	var smartTargetsCount: Int { get }
	var oldSmartTargetCollection: ISmartTargetCollection { get }
	var smartTargetCollection: ISmartTargetCollection { get }
	var editedSmartTarget: SmartTarget? { get set }
	var didUpdateAllSmartTargets: Bool { get set }
}

// MARK: - Class
final class SmartTargetListInteractor<T: ISmartTargetRepository>
{
	// MARK: ...Private properties
	private var presenter: SmartTargetListPresentationLogic
	private let dataBaseWorker: DataBaseWorker<T>
	private let settingsWorker: SettingsWorker

	// MARK: ...Map data store
	let oldSmartTargetCollection: ISmartTargetCollection
	let smartTargetCollection: ISmartTargetCollection
	var didUpdateAllSmartTargets = false
	var editedSmartTarget: SmartTarget?

	// MARK: ...Initialization
	init(presenter: SmartTargetListPresentationLogic,
		 dataBaseWorker: DataBaseWorker<T>,
		 settingsWorker: SettingsWorker,
		 collection: ISmartTargetCollection,
		 oldCollection: ISmartTargetCollection) {
		self.presenter = presenter
		self.dataBaseWorker = dataBaseWorker
		self.settingsWorker = settingsWorker
		self.smartTargetCollection = collection
		self.oldSmartTargetCollection = oldCollection
	}
}

// MARK: - Smart target list business logic
extension SmartTargetListInteractor: SmartTargetListBusinessLogic
{
	func deleteSmartTargets(_ request: SmartTargetList.DeleteSmartTargets.Request) {
		request.smartTargetsIndexSet.forEach { index in
			let uuid = self.smartTargetCollection.smartTargets[Int(index)].uid
			self.smartTargetCollection.remove(atUID: uuid)
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
		guard didUpdateAllSmartTargets == false else { return }
		let oldCollection = oldSmartTargetCollection.copy()

		let difference = smartTargetCollection.smartTargetsOfDifference(from: oldCollection)
		let response = SmartTargetList.UpdateSmartTargets.Response(collection: oldCollection,
																   difference: difference)

		oldSmartTargetCollection.replaceSmartTargets(with: smartTargetCollection.smartTargets)
		presenter.presentUpdateSmartTargets(response)
		didUpdateAllSmartTargets = true
	}

	func updateSmartTarget(_ request: SmartTargetList.UpdateSmartTarget.Request) {
		guard editedSmartTarget != nil,
			let editedSmartTarget = self.editedSmartTarget,
			let oldSmartTarget = self.smartTargetCollection[editedSmartTarget.uid] else { return }
		let smartTargetIndex = smartTargetCollection.put(editedSmartTarget)
		self.editedSmartTarget = nil
		let response = SmartTargetList.UpdateSmartTarget.Response(editedSmartTarget: editedSmartTarget,
																  oldSmartTarget: oldSmartTarget,
																  editedSmartTargetIndex: smartTargetIndex)
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
		smartTargetCollection.count
	}
}
