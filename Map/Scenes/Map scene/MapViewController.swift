//
//  MapViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//
// swiftlint:disable file_length
import MapKit

// MARK: - MapDisplayLogic protocol
protocol MapDisplayLogic: AnyObject
{
	func displaySmartTargets(viewModel: Map.SmartTargets.ViewModel)
	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel)
	func displayAddress(viewModel: Map.Address.ViewModel)
}

// MARK: - Class
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
	private var isAnimateMapView = false
	private var willTranslateKeyboard = false

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
	private var smartTargetMenuBottomLayoutConstraint: NSLayoutConstraint?
	private var smartTargetMenuLeadingLayoutConstraint: NSLayoutConstraint?
	private var smartTargetMenuTopLayoutConstraint: NSLayoutConstraint?

	// Constraints of map view
	private var mapViewBottomLayoutConstraint: NSLayoutConstraint?

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
		addNotifications()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		removeNotifications()
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
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapViewBottomLayoutConstraint = mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		mapViewBottomLayoutConstraint?.isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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

		smartTargetMenuBottomLayoutConstraint =
			smartTargetMenu?
				.bottomAnchor
				.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
							constant: -currentLocationOffset)
		smartTargetMenuBottomLayoutConstraint?.isActive = true

		smartTargetMenuLeadingLayoutConstraint =
			smartTargetMenu?
				.leadingAnchor
				.constraint(equalTo: addButtonView.leadingAnchor)
		smartTargetMenuLeadingLayoutConstraint?.isActive = true

		smartTargetMenu?
			.trailingAnchor
			.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
						constant: -currentLocationOffset)
			.isActive = true
	}

	private func addNotifications() {
		// Add keyboard notifications
		NotificationCenter
			.default
			.addObserver(self, selector: #selector(keyboardWillAppear),
						 name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter
			.default
			.addObserver(self, selector: #selector(keyboardWillDisappear),
						 name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter
			.default
			.addObserver(self, selector: #selector(keyboardDidAppear),
						 name: UIResponder.keyboardDidShowNotification, object: nil)
		NotificationCenter
			.default
			.addObserver(self, selector: #selector(keyboardDidDisappear),
						 name: UIResponder.keyboardDidHideNotification, object: nil)
	}

	private func removeNotifications() {
		// Remove keyboard notifications
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
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

	private func showSmartTargetMenu() {
		let menu =
			SmartTargetMenu(radiusValue: 300, radiusRange: (50, 1000), saveAction: { [weak self] _ in
				self?.temptPointer = nil
				self?.addButtonView.isHidden = false
				self?.smartTargetMenu = nil
			}, cancelAction: { [weak self] _ in
				guard let temptPointer = self?.temptPointer else { return }
				self?.mapView.removeAnnotation(temptPointer)
				self?.temptPointer = nil
				self?.addButtonView.isHidden = false
				self?.smartTargetMenu = nil
			}, radiusChange: { _, radius in
				print(radius)
			})

		smartTargetMenu = menu

		view.addSubview(menu)

		setupSmartTargetMenuConstraints()
		view.layoutIfNeeded()

		UIView.animate(withDuration: 0.3) {
			self.smartTargetMenuBottomLayoutConstraint?.constant = -self.currentLocationOffset
			self.smartTargetMenuLeadingLayoutConstraint?.isActive = false
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
		UIView.animate(withDuration: 0.3) {
			guard
				let bottomSmartTargetMenuConstraint = self.smartTargetMenuBottomLayoutConstraint,
				let smartTargetMenu = self.smartTargetMenu else { return }
			let factor: CGFloat = flag ? 1 : -1
			let offset = smartTargetMenu.frame.height / 2 * factor
			bottomSmartTargetMenuConstraint.constant += offset
			self.view.layoutIfNeeded()
		}
	}

	private func animateMapViewFrame(withBottomOffset constant: CGFloat, layoutIfNeeded: Bool = true) {
		isAnimateMapView = true
		UIView.animate(withDuration: 0.5, animations: {
			self.mapViewBottomLayoutConstraint?.constant = constant
			if layoutIfNeeded {
				self.view.layoutIfNeeded()
			}
		}, completion: { _ in
			guard let pointer = self.temptPointer else { return }
			self.showLocation(coordinate: pointer.coordinate)
			self.isAnimateMapView = true
		})
	}

	private func animateSmartTargetMenu(withBottomOffset constant: CGFloat, layoutIfNeeded: Bool = true) {
		UIView.animate(withDuration: 0.5) {
			self.smartTargetMenuBottomLayoutConstraint?.constant += constant
			if layoutIfNeeded {
				self.view.layoutIfNeeded()
			}
		}
	}
}

// MARK: - Actions
private extension MapViewController
{
	func actionCreateSmartTarget() {
		addButtonView.isHidden = true
		addTemptPointer()
		showSmartTargetMenu()
		interactor.getAddress(request: Map.Address.Request(coordinate: mapView.centerCoordinate))
	}
}

// MARK: - Notifications
@objc private extension MapViewController
{
	func keyboardWillAppear(notification: NSNotification?) {
		willTranslateKeyboard = true
		guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}
		let keyboardHeight = keyboardFrame.cgRectValue.height
		animateMapViewFrame(withBottomOffset: -keyboardHeight)
		animateSmartTargetMenu(withBottomOffset: -keyboardHeight / 3)
	}

	func keyboardWillDisappear(notification: NSNotification?) {
		willTranslateKeyboard = true
		guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}
		let keyboardHeight = keyboardFrame.cgRectValue.height
		animateMapViewFrame(withBottomOffset: 0, layoutIfNeeded: false)
		animateSmartTargetMenu(withBottomOffset: keyboardHeight / 3, layoutIfNeeded: false)
	}

	func keyboardDidAppear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func keyboardDidDisappear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}
}

// MARK: - Map display logic
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
		if willTranslateKeyboard == false {
			hideSmartTargetMenu(true)
			smartTargetMenu?.address = nil
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if willTranslateKeyboard == false && isAnimateMapView == false {
			hideSmartTargetMenu(false)
		}
		guard let temptPointer = temptPointer,
			isDraggedTemptPointer == false,
			isAnimateMapView == false else {
				isDraggedTemptPointer = false
				isAnimateMapView = false
				return
		}
		mapView.removeAnnotation(temptPointer)
		temptPointer.coordinate = mapView.centerCoordinate
		mapView.addAnnotation(temptPointer)
		interactor.getAddress(request: Map.Address.Request(coordinate: mapView.centerCoordinate))
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
			interactor.getAddress(request: Map.Address.Request(coordinate: mapView.centerCoordinate))
		case (.starting, .none):
			hideSmartTargetMenu(true)
			smartTargetMenu?.address = nil
		default: break
		}
	}
}
