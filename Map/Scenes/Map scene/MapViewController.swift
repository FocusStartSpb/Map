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

	private lazy var mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.delegate = self
		return mapView
	}()

	private let currentLocationButton = UIButton()
	private lazy var addButtonView = AddButtonView(tapAction: actionCreateSmartTarget)

	private var smartTargetMenu: SmartTargetMenu?
	private var temptPointer: SmartTargetAnnotation?

	private var isEditSmartTarget: Bool { temptPointer != nil }
	private var isDraggedTemptPointer = false
	private var circleRadius = 300.0
	private var temptCircle: MKCircle?

	private var annotations: [SmartTargetAnnotation] {
		mapView
			.annotations
			.filter { $0 is SmartTargetAnnotation }
			.compactMap { $0 as? SmartTargetAnnotation }
	}

	private let latitudalMeters = 5_000.0
	private let longtitudalMeters = 5_000.0
	private let currentLocationButtonSize: CGFloat = 40.0
	private let currentLocationOffset: CGFloat = 20.0

	// Constraints of smart target menu
	private var bottomSmartTargetMenuConstraint: NSLayoutConstraint?
	private var leadingSmartTargetMenuConstraint: NSLayoutConstraint?
	private var topSmartTargetMenuConstraint: NSLayoutConstraint?

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
		view.addSubview(addButtonView)

		setupCurrentLocationButton()

		setupMapConstraints()
		setupCurrentLocationButtonConstraints()
		setupAddButtonViewConstraints()

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

	private func setupAddButtonViewConstraints() {
		addButtonView.translatesAutoresizingMaskIntoConstraints = false

		addButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
												constant: -currentLocationOffset).isActive = true
		addButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
											  constant: -currentLocationOffset).isActive = true
		addButtonView.heightAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
		addButtonView.widthAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
	}

	private func setupSmartTargetMenuConstraints() {
		smartTargetMenu?.translatesAutoresizingMaskIntoConstraints = false

		bottomSmartTargetMenuConstraint =
			smartTargetMenu?
				.bottomAnchor
				.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
							constant: -currentLocationOffset)
		bottomSmartTargetMenuConstraint?.isActive = true

		leadingSmartTargetMenuConstraint =
			smartTargetMenu?
				.leadingAnchor
				.constraint(equalTo: addButtonView.leadingAnchor)
		leadingSmartTargetMenuConstraint?.isActive = true

		smartTargetMenu?
			.trailingAnchor
			.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
						constant: -currentLocationOffset)
			.isActive = true
	}

	private func showLocation(coordinate: CLLocationCoordinate2D) {
		let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.latitudalMeters,
											longitudinalMeters: self.longtitudalMeters)
		mapView.setRegion(zoomRegion, animated: true)
	}

	private func addTemptPointer() {
		let annotation = SmartTargetAnnotation(title: nil,
											   coordinate: mapView.centerCoordinate)
		mapView.addAnnotation(annotation)
		temptPointer = annotation
	}

	private func removeTemptCircle() {
		guard let temptCircle = temptCircle else { return }
		mapView.removeOverlay(temptCircle)
		self.temptCircle = nil
	}

	private func addTemptCircle(with radius: Double) {
		removeTemptCircle()
		temptCircle = MKCircle(center: mapView.centerCoordinate, radius: radius)
		guard let temptCircle = temptCircle else { return }
		mapView.addOverlay(temptCircle)
	}

	private func showSmartTargetMenu() {
		let initialRadius = 300.0
		let menu =
			SmartTargetMenu(radiusValue: Float(initialRadius), radiusRange: (50, 1000), saveAction: { [weak self] _ in
				self?.temptPointer = nil
				self?.addButtonView.isHidden = false
				self?.smartTargetMenu = nil
				self?.circleRadius = initialRadius
			}, cancelAction: { [weak self] _ in
				guard let temptPointer = self?.temptPointer else { return }
				self?.mapView.removeAnnotation(temptPointer)
				self?.temptPointer = nil
				self?.addButtonView.isHidden = false
				self?.smartTargetMenu = nil
				self?.removeTemptCircle()
			}, radiusChange: { _, radius in
				self.circleRadius = Double(radius)
				self.addTemptCircle(with: Double(radius))
			})

		smartTargetMenu = menu

		view.addSubview(menu)

		setupSmartTargetMenuConstraints()
		view.layoutIfNeeded()

		UIView.animate(withDuration: 0.3) { [weak self] in
			guard let self = self else { return }
			self.bottomSmartTargetMenuConstraint?.constant = -self.currentLocationOffset
			self.leadingSmartTargetMenuConstraint?.isActive = false
			self.smartTargetMenu?
				.leadingAnchor
				.constraint(equalTo: self.view.leadingAnchor,
							constant: self.currentLocationOffset)
				.isActive = true
			self.view.layoutIfNeeded()
		}
	}

	private func hideSmartTargetMenu(_ flag: Bool) {
		smartTargetMenu?.translucent(flag, value: 0.5)
		translationSmartTargetMenu(flag)
	}

	private func translationSmartTargetMenu(_ flag: Bool) {
		UIView.animate(withDuration: 0.3) { [weak self] in
			guard
				let self = self,
				let bottomSmartTargetMenuConstraint = self.bottomSmartTargetMenuConstraint,
				let smartTargetMenu = self.smartTargetMenu else { return }
			let factor: CGFloat = flag ? 1 : -1
			let offset = smartTargetMenu.frame.height / 2 * factor
			bottomSmartTargetMenuConstraint.constant += offset
			self.view.layoutIfNeeded()
		}
	}
}

// MARK: - Actions
private extension MapViewController
{
	func actionCreateSmartTarget() {
		addButtonView.isHidden = true
		addTemptPointer()
		addTemptCircle(with: circleRadius)
		showSmartTargetMenu()
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
		guard viewModel.isShownUserPosition else {
			currentLocationButton.isHidden = true
			return
		}
		currentLocationButton.isHidden = false
		guard let coordinate = viewModel.userCoordinate else { return }
		showLocation(coordinate: coordinate)
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

// MARK: - Map view delegate
extension MapViewController: MKMapViewDelegate
{
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation { return nil }
		var pinView =
			mapView.dequeueReusableAnnotationView(withIdentifier: SmartTargetAnnotation.identifier) as? MKPinAnnotationView
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation,
										  reuseIdentifier: SmartTargetAnnotation.identifier)
			pinView?.isDraggable = true
			pinView?.animatesDrop = true
			pinView?.canShowCallout = true
		}
		else {
			pinView?.annotation = annotation
		}
		return pinView
	}

	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		removeTemptCircle()
		hideSmartTargetMenu(true)
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		hideSmartTargetMenu(false)

		guard let temptPointer = temptPointer, isDraggedTemptPointer == false else {
			isDraggedTemptPointer = false
			return
		}
		mapView.removeAnnotation(temptPointer)
		temptPointer.coordinate = mapView.centerCoordinate
		addTemptCircle(with: circleRadius)
		mapView.addAnnotation(temptPointer)
	}

	func mapView(_ mapView: MKMapView,
				 annotationView view: MKAnnotationView,
				 didChange newState: MKAnnotationView.DragState,
				 fromOldState oldState: MKAnnotationView.DragState) {
		switch (newState, oldState) {
		case (.none, .ending):
			guard let temptPointer = temptPointer else { return }
			isDraggedTemptPointer = true
			showLocation(coordinate: temptPointer.coordinate)
			hideSmartTargetMenu(false)
		case (.starting, .none):
			hideSmartTargetMenu(true)
		default: break
		}
	}
}
