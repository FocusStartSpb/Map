//
//  SmartTargetListPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListPresentationLogic
protocol SmartTargetListPresentationLogic
{
	func presentSmartTargets(response: SmartTargetList.SmartTargets.Response)
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
	func presentSmartTargets(response: SmartTargetList.SmartTargets.Response) {
		let viewModel = SmartTargetList.SmartTargets.ViewModel(smartTargets: response.smartTargets)
		viewController?.displaySmartTargets(viewModel: viewModel)
	}
}
