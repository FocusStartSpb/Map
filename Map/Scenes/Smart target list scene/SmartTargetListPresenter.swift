//
//  SmartTargetListPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListPresentationLogic
protocol SmartTargetListPresentationLogic
{
	func presentLoadSmartTargets(_ response: SmartTargetList.LoadSmartTargets.Response)
	func presentSaveSmartTargets(_ response: SmartTargetList.SaveSmartTargets.Response)
}

// MARK: - Class
final class SmartTargetListPresenter
{
	// MARK: ...Internal properties
	weak var viewController: SmartTargetListDisplayLogic?
}

// MARK: - Smart target list presentation logic
extension SmartTargetListPresenter: SmartTargetListPresentationLogic
{
	func presentLoadSmartTargets(_ response: SmartTargetList.LoadSmartTargets.Response) {
		let didLoad: Bool
		switch response.result {
		case .success:
			didLoad = true
		case .failure(let error):
			didLoad = false
			print(error)
		}
		let viewModel = SmartTargetList.LoadSmartTargets.ViewModel(didLoad: didLoad)
		viewController?.displayLoadSmartTargets(viewModel)
	}

	func presentSaveSmartTargets(_ response: SmartTargetList.SaveSmartTargets.Response) {
		let didSave: Bool
		switch response.result {
		case .success:
			didSave = true
		case .failure(let error):
			didSave = false
			print(error)
		}
		let viewModel = SmartTargetList.SaveSmartTargets.ViewModel(didSave: didSave)
		viewController?.displaySaveSmartTargets(viewModel)
	}
}
