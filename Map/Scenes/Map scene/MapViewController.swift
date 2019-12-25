//
//  MapViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import MapKit

// MARK: MapDisplayLogic protocol
protocol MapDisplayLogic: AnyObject
{
	func displaySmartTargets(viewModel: Map.SmartTargets.ViewModel)
	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel)
	func displayAddress(viewModel: Map.Address.ViewModel)
}

// MARK: Class
final class MapViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: MapBusinessLogic

	private let mapView = MKMapView()
	private let currentLocationButton = UIButton()

	private let latitudalMeters = 5_000.0
	private let longtitudalMeters = 5_000.0
	private let currentLocationButtonSize: CGFloat = 40.0
	private let currentLocationOffset: CGFloat = 20.0

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
		setup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		currentLocationButton.isHidden = (mapView.showsUserLocation == false)
	}

	// MARK: ...Private methods
	private func setup() {
		view.addSubview(mapView)
		view.addSubview(currentLocationButton)

		setupCurrentLocationButton()

		setupMapConstraints()
		setupCurrentLocationButtonConstraints()

		interactor.configureLocationService(request: .init())
		doSomething()
	}

	private func doSomething() {
		let request = Map.SmartTargets.Request()
		interactor.getSmartTargets(request: request)
	}

	@objc private func currentLocationPressed(sender: UIButton) {
		interactor.returnToCurrentLocation(request: Map.UpdateStatus.Request())
	}

	private func setupCurrentLocationButton() {
		currentLocationButton.setTitle("➤", for: .normal)
		currentLocationButton.titleLabel?.font = .systemFont(ofSize: 40)
		currentLocationButton.setTitleColor(.systemBlue, for: .normal)
		currentLocationButton.transform = CGAffineTransform(rotationAngle: -45.0)
		currentLocationButton.layer.cornerRadius = 20
		currentLocationButton.addTarget(self, action: #selector(currentLocationPressed), for: .touchUpInside)
		currentLocationButton.isHidden = true
	}

	private func setupMapConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
	}

	private func setupCurrentLocationButtonConstraints() {
		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
		currentLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
													  constant: currentLocationOffset).isActive = true
		currentLocationButton.heightAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
		currentLocationButton.widthAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
		currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
														constant: -currentLocationOffset).isActive = true
	}

	private func showLocation(coordinate: CLLocationCoordinate2D) {
		let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.latitudalMeters,
											longitudinalMeters: self.longtitudalMeters)
		mapView.setRegion(zoomRegion, animated: true)
	}
}

// MARK: Map display logic
extension MapViewController: MapDisplayLogic
{
	func displaySmartTargets(viewModel: Map.SmartTargets.ViewModel) {
		//nameTextField.text = viewModel.name
	}

	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel) {
		mapView.showsUserLocation = viewModel.isShownUserPosition
		if viewModel.isShownUserPosition {
			currentLocationButton.isHidden = false
			guard let coordinate = viewModel.userCoordinate else { return }
			showLocation(coordinate: coordinate)
		}
	}

	func displayAddress(viewModel: Map.Address.ViewModel) {
		guard let menu = smartTargetMenu else { return }
		switch viewModel.result {
		case .success(let address):
			menu.address = address
		case .failure(let error):
			menu.address = error.localizedDescription
		}
	}
}
