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
	private var smartTargetMenuBottomLayoutConstraint: NSLayoutConstraint?
	private var smartTargetMenuLeadingLayoutConstraint: NSLayoutConstraint?
	private var smartTargetMenuTopLayoutConstraint: NSLayoutConstraint?

	private var smartTargetMenuBottomConstant: CGFloat = 0

	// Constraints of map view
	private var mapViewBottomLayoutConstraint: NSLayoutConstraint?

	private var translationOfHideSmartTargetMenuOffset: CGFloat?

	// Notifications
	private let notificationCenter = NotificationCenter.default

	private let keyboardNotifications: [NSNotification.Name: Selector] = [
		UIResponder.keyboardWillShowNotification: #selector(keyboardWillAppear),
		UIResponder.keyboardWillHideNotification: #selector(keyboardWillDisappear),
		UIResponder.keyboardDidShowNotification: #selector(keyboardDidAppear),
		UIResponder.keyboardDidHideNotification: #selector(keyboardDidDisappear),
	]

	private let applicationNotifications: [NSNotification.Name: Selector] = [
		UIApplication.willResignActiveNotification: #selector(appMovedToBackground),
		UIApplication.didBecomeActiveNotification: #selector(appMovedFromBackground),
	]

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
		notificationCenter.addObserver(self, notifications: applicationNotifications)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		notificationCenter.removeObserver(self, names: Set(applicationNotifications.keys))
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

	// MARK: ...Setup constraints
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

	// MARK: ...Setup notifications
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

	// MARK: ...Ather
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

	private func addTemptCircle(at coordinate: CLLocationCoordinate2D, with radius: Double) {
		temptCircle = MKCircle(center: coordinate, radius: radius)
		guard let temptCircle = temptCircle else { return }
		mapView.addOverlay(temptCircle)
	}

	private func showSmartTargetMenu() {
		let menu =
			SmartTargetMenu(radiusValue: Float(self.circleRadius), radiusRange: (50, 1000), saveAction: { [weak self] _ in
				guard let self = self, let temptPointer = self.temptPointer else { return }
				self.mapView.view(for: temptPointer)?.isDraggable = false
				self.temptPointer = nil
				self.addButtonView.isHidden = false
				self.smartTargetMenu = nil
			}, cancelAction: { [weak self] _ in
				guard let temptPointer = self?.temptPointer else { return }
				self?.mapView.removeAnnotation(temptPointer)
				self?.temptPointer = nil
				self?.addButtonView.isHidden = false
				self?.smartTargetMenu = nil
				self?.removeTemptCircle()
			}, radiusChange: { [weak self] _, radius in
				guard let self = self else { return }
				self.circleRadius = Double(radius)
				self.removeTemptCircle()
				self.addTemptCircle(at: self.mapView.centerCoordinate, with: Double(radius))
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

	// MARK: ...Animations
	private func animateSmartTargetMenu(hide flag: Bool) {
		guard
			let bottomSmartTargetMenuConstraint = smartTargetMenuBottomLayoutConstraint,
			let smartTargetMenu = smartTargetMenu else { return }
		if flag { translationOfHideSmartTargetMenuOffset = nil }
		let factor: CGFloat = flag ? 1 : -1
		let offset = (translationOfHideSmartTargetMenuOffset ?? smartTargetMenu.frame.height / 2) * factor
		translationOfHideSmartTargetMenuOffset = offset
		let constant = bottomSmartTargetMenuConstraint.constant + offset

		smartTargetMenu.translucent(flag, value: 0.5)
		animateSmartTargetMenu(withBottomOffset: constant, layoutIfNeeded: true)
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
			self.smartTargetMenuBottomLayoutConstraint?.constant = constant
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
		removeTemptCircle()
		addTemptCircle(at: mapView.centerCoordinate, with: circleRadius)
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
		smartTargetMenuBottomConstant = -keyboardHeight / 3 - currentLocationOffset
		animateSmartTargetMenu(withBottomOffset: smartTargetMenuBottomConstant)
	}

	func keyboardWillDisappear(notification: NSNotification?) {
		willTranslateKeyboard = true
		animateMapViewFrame(withBottomOffset: 0, layoutIfNeeded: false)
		smartTargetMenuBottomConstant = -currentLocationOffset
		animateSmartTargetMenu(withBottomOffset: smartTargetMenuBottomConstant, layoutIfNeeded: false)
	}

	func keyboardDidAppear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func keyboardDidDisappear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func appMovedFromBackground() {
		notificationCenter.addObserver(self, notifications: keyboardNotifications)
	}

	func appMovedToBackground() {
		notificationCenter.removeObserver(self, names: Set(keyboardNotifications.keys))
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
			pinView?.animatesDrop = true
		}
		else {
			pinView?.annotation = annotation
			pinView?.animatesDrop = false
		}
		pinView?.isDraggable = true
		pinView?.canShowCallout = true
		return pinView
	}

	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		guard willTranslateKeyboard == false, isDraggedTemptPointer == false else { return }
		animateSmartTargetMenu(hide: true)
		smartTargetMenu?.address = nil
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		guard let temptPointer = temptPointer,
			isDraggedTemptPointer == false,
			isAnimateMapView == false else { return }

		// Update pointer annotation
		mapView.removeAnnotation(temptPointer)
		temptPointer.coordinate = mapView.centerCoordinate
		mapView.addAnnotation(temptPointer)

		// Update circe overlay
		removeTemptCircle()
		addTemptCircle(at: mapView.centerCoordinate, with: circleRadius)
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		guard let temptPointer = self.temptPointer,
			isAnimateMapView == false,
			isDraggedTemptPointer == false else {
			isAnimateMapView = false
			isDraggedTemptPointer = false
			return
		}
		if willTranslateKeyboard == false {
			animateSmartTargetMenu(hide: false)
		}
		interactor.getAddress(request: Map.Address.Request(coordinate: temptPointer.coordinate))
	}

	func mapView(_ mapView: MKMapView,
				 annotationView view: MKAnnotationView,
				 didChange newState: MKAnnotationView.DragState,
				 fromOldState oldState: MKAnnotationView.DragState) {
		isDraggedTemptPointer = true
		switch (oldState, newState) {
		case (.none, .starting): // 0 - 1
			animateSmartTargetMenu(hide: true)
			removeTemptCircle()
		case (.starting, .dragging): // 1 - 2
			smartTargetMenu?.address = nil
		case (.canceling, .none): // 3 - 0
			guard let temptPointer = temptPointer else { return }
			animateSmartTargetMenu(hide: false)
			addTemptCircle(at: temptPointer.coordinate, with: circleRadius)
		case (.ending, .none): // 4 - 0
			guard let temptPointer = temptPointer else { return }
			showLocation(coordinate: temptPointer.coordinate)
			animateSmartTargetMenu(hide: false)
			interactor.getAddress(request: Map.Address.Request(coordinate: mapView.centerCoordinate))
			addTemptCircle(at: temptPointer.coordinate, with: circleRadius)
		default: break
		}
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKCircleRenderer(overlay: overlay)
		if #available(iOS 13.0, *) {
			renderer.fillColor = UIColor.systemBackground.withAlphaComponent(0.5)
		}
		else {
			renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
		}
		renderer.strokeColor = .systemBlue
		renderer.lineWidth = 1
		return renderer
	}
}
