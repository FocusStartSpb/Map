//
//  MapViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import UIKit
import MapKit

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

	let mapView = MKMapView()

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
		view.addSubview(mapView)
		setupMapConstraints()
		doSomething()
	}

	// MARK: ...Private methods
	private func doSomething() {
		let request = Map.SmartTargets.Request()
		interactor.getSmartTargets(request: request)
	}

	private func setupMapConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
	}
}

// MARK: Map display logic
extension MapViewController: MapDisplayLogic
{
	func displaySmartTargets(viewModel: Map.SmartTargets.ViewModel) {
		//nameTextField.text = viewModel.name
	}
}
