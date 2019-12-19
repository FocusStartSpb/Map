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
	func showLocation(viewModel: Map.UpdateLocation.ViewModel)
	func beginLocationUpdates(viewModel: CLLocationManager)
}

// MARK: Class
final class MapViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: MapBusinessLogic

	let mapView = MKMapView()
	let locationManager = CLLocationManager()

	let latitudalMeters = 5_000.0
	let longtitudalMeters = 5_000.0

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
		configureLocationService()
		doSomething()
	}

	// MARK: ...Private methods
	private func doSomething() {
		let request = Map.SmartTargets.Request()
		interactor.getSmartTargets(request: request)
	}
	private func configureLocationService() {
		locationManager.delegate = self

		let status = CLLocationManager.authorizationStatus()
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			beginLocationUpdates(viewModel: locationManager)
		}
		else {
			locationManager.requestAlwaysAuthorization()
		}
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

	func showLocation(viewModel: Map.UpdateLocation.ViewModel) {
		let zoomRegion = MKCoordinateRegion(center: viewModel.coordinate, latitudinalMeters: self.latitudalMeters,
											longitudinalMeters: self.longtitudalMeters)
		self.mapView.setRegion(zoomRegion, animated: true)
	}
	func beginLocationUpdates(viewModel: CLLocationManager) {
		mapView.showsUserLocation = true
		viewModel.desiredAccuracy = kCLLocationAccuracyBest
		viewModel.startUpdatingLocation()
	}
}

// MARK: - CLLocationDelegate

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		interactor.getCurrentCoordinate(request: Map.UpdateLocation.Request(locations: locations))
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			beginLocationUpdates(viewModel: manager)
		}
	}
}
