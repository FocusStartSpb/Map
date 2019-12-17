//
//  MapViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import UIKit

// MARK: MapDisplayLogic protocol
protocol MapDisplayLogic: AnyObject
{
	func displaySmartTargets(viewModel: Map.SmartTargets.ViewModel)
}

// MARK: Class
final class MapViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: MapBusinessLogic

	// MARK: ...Initialization
	init(interactor: MapBusinessLogic) {
		self.interactor = interactor
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
	private func doSomething() {
		let request = Map.SmartTargets.Request()
		interactor.getSmartTargets(request: request)
	}
}

// MARK: Map display logic
extension MapViewController: MapDisplayLogic
{
	func displaySmartTargets(viewModel: Map.SmartTargets.ViewModel) {
		//nameTextField.text = viewModel.name
	}
}
