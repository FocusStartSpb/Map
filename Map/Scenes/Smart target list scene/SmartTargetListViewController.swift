//
//  SmartTargetListViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import UIKit

// MARK: - SmartTargetListDisplayLogic protocol
protocol SmartTargetListDisplayLogic: AnyObject
{
	func displaySmartTargets(viewModel: SmartTargetList.SmartTargets.ViewModel)
}

// MARK: - Class
final class SmartTargetListViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: SmartTargetListBusinessLogic
	private var router: (SmartTargetListRoutingLogic & SmartTargetListDataPassing)

	// MARK: ...Initialization
	init(interactor: SmartTargetListBusinessLogic,
		 router: (SmartTargetListRoutingLogic & SmartTargetListDataPassing)) {
		self.interactor = interactor
		self.router = router
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		doSomething()
	}

	// MARK: ...Private methods
	func doSomething() {
		let request = SmartTargetList.SmartTargets.Request()
		interactor.doSmartTargets(request: request)
	}
}

// MARK: - Smart target list display logic
extension SmartTargetListViewController: SmartTargetListDisplayLogic
{
	func displaySmartTargets(viewModel: SmartTargetList.SmartTargets.ViewModel) {
	}
}
