//
//  MapViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//
// swiftlint:disable file_length
import MapKit

// MARK: - Class
final class MapViewController: UIViewController
{
	enum Mode
	{
		case edit, add, none
	}

	// MARK: ...Private properties
	var interactor: MapBusinessLogic & MapDataStore
	var router: MapRoutingLogic & MapDataPassing

	// UI elements
	let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: Constants.ImpactFeedbackGeneratorStyle.dropPin)

	private(set) lazy var mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.showsCompass = false
		mapView.delegate = self
		return mapView
	}()

	private(set) lazy var currentLocationButton: ButtonView = {
		let view = ButtonView(type: .currentLocation, tapAction: actionCurrentLocation)
		view.isHidden = true
		return view
	}()
	private(set) lazy var addButtonView = ButtonView(type: .add, tapAction: actionCreateSmartTarget)

	private(set) var smartTargetMenu: SmartTargetMenu?

	// Tempt annotation
	var currentPointer: SmartTargetAnnotation?
	var temptLastPointer: SmartTargetAnnotation?
	// Tempt overlay
	private(set) var temptCircle: MKCircle?

	private lazy var saveAction = MenuAction(title: "Save", style: .default, handler: actionSave)
	private lazy var removeAction = MenuAction(title: "Remove", style: .destructive, handler: actionRemove)
	private(set) lazy var cancelAction = MenuAction(title: "Cancel", style: .cancel, handler: actionChooseActionForPin)

	// Editing properties
	var mode: Mode = .none
	var isEditSmartTarget = false
	var isDraggedTemptPointer = false
	var isNewPointer = false
	var isAnimateMapView = false
	private(set) var isAnimateSmartTargetMenu = false
	var regionIsChanging = false
	var circleRadius = Constants.Radius.defaultValue

	var removePinWithoutAlertRestricted = true
	var removePinAlertOn = true

	var willTranslateKeyboard = false
	var isObservableToKeyboard = false
	var keyboardIsVisible = false

	// Calculated properties
	var annotations: [SmartTargetAnnotation] {
		mapView.annotations.compactMap { $0 as? SmartTargetAnnotation }
	}

	// Constraints of smart target menu
	private var smartTargetMenuBottomLayoutConstraint: NSLayoutConstraint?

	// Constraints of map view
	private var mapViewBottomLayoutConstraint: NSLayoutConstraint?

	private var translationOfHideSmartTargetMenuOffset: CGFloat?

	// MARK: ...Initialization
	init(interactor: MapBusinessLogic & MapDataStore, router: MapRoutingLogic & MapDataPassing) {
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
		setup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		tabBarController?.delegate = self

		setupNotifications()

		// Send Requests
		let updateSmartTargetsRequest = Map.UpdateAnnotations.Request(annotations: annotations)
		interactor.updateAnnotations(updateSmartTargetsRequest)
		interactor.measurementSystem(.init())
		interactor.getRemovePinAlertSettings(.init())
		interactor.getCurrentRadius(.init(currentRadius: circleRadius))
		let updateStatusRequest = Map.UpdateStatus.Request()
		interactor.configureLocationService(request: updateStatusRequest)
		removePinWithoutAlertRestricted = true
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		removeNotifications()
	}

	// MARK: ...Private methods
	private func setup() {

		// Add subviews
		view.addSubview(mapView)
		view.addSubview(currentLocationButton)
		view.addSubview(addButtonView)

		// Constraints
		setupMapConstraints()
		setupCurrentLocationButtonConstraints()
		setupAddButtonViewConstraints()

		// Requests
		let fetchSmartTardetRequest = Map.FetchAnnotations.Request()
		interactor.getAnnotations(fetchSmartTardetRequest)

		let notificationRequest = Map.SetNotificationServiceDelegate.Request(notificationDelegate: self)
		interactor.setNotificationServiceDelegate(notificationRequest)

		let request = Map.GetCurrentRadius.Request(currentRadius: circleRadius)
		interactor.getCurrentRadius(request)
	}

	private func setupDefaultSettings() {
		mode = .none
		currentPointer = nil
		smartTargetMenu = nil
		temptLastPointer = nil
		interactor.temptSmartTarget = nil
		removeTemptCircle()
		setTabBarVisible(true)

		addButtonView.isHidden = false
		isEditSmartTarget = false
		isAnimateMapView = false
		isDraggedTemptPointer = false
		removePinWithoutAlertRestricted = true

		interactor.getCurrentRadius(.init(currentRadius: circleRadius))
	}

	private func createSmartTargetMenu() -> SmartTargetMenu {
		SmartTargetMenu(textField: interactor.temptSmartTarget?.title,
						sliderValue: interactor.temptSmartTarget?.radius ?? circleRadius,
						sliderValuesRange: (Constants.Radius.defaultLowerValue, Constants.Radius.defaultUpperValue),
						title: interactor.temptSmartTarget?.address,
						leftAction: removeAction,
						rightAction: saveAction,
						sliderAction: actionChangeRadius,
						textFieldAction: actionChangeTitle)
	}

	// MARK: ...Internal methods
	func setAnnotationView(_ annotationView: MKAnnotationView?, draggable: Bool, andShowCallout canShowCallout: Bool) {
		annotationView?.isDraggable = draggable
		annotationView?.canShowCallout = canShowCallout
	}

	func addCurrentPointer(at coordinate: CLLocationCoordinate2D) {
		guard let target = interactor.temptSmartTarget else { return }
		let annotation = target.annotation
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		currentPointer = annotation
	}

	func addTemptCircle(at coordinate: CLLocationCoordinate2D, with radius: Double) {
		temptCircle = MKCircle(center: coordinate, radius: radius)
		guard let temptCircle = temptCircle else { return }
		mapView.addOverlay(temptCircle)
	}

	func removeTemptCircle() {
		guard let temptCircle = temptCircle else { return }
		mapView.removeOverlay(temptCircle)
		self.temptCircle = nil
	}

	func showSmartTargetMenu() {
		let menu = createSmartTargetMenu()
		smartTargetMenu = menu

		interactor.getRangeRadius(.init())
		interactor.getCurrentRadius(.init(currentRadius: circleRadius))
		interactor.measurementSystem(.init())

		view.addSubview(menu)
		setupSmartTargetMenuConstraints()

		animateShowMenu()
	}
}

// MARK: - Animations
extension MapViewController
{
	private func animateShowMenu() {
		view.layoutIfNeeded()

		smartTargetMenu?.transform = CGAffineTransform(translationX: 0, y: smartTargetMenu?.frame.height ?? 0)
		smartTargetMenu?.alpha = 0

		UIView.animate(withDuration: 0.5,
					   delay: 0,
					   usingSpringWithDamping: 0.6,
					   initialSpringVelocity: 1,
					   options: .layoutSubviews,
					   animations: {
						self.isAnimateSmartTargetMenu = true
						self.smartTargetMenu?.alpha = 1
						self.smartTargetMenu?.transform = .identity
		}, completion: { _ in
			self.isAnimateSmartTargetMenu = false
			if self.regionIsChanging, self.isEditSmartTarget {
				self.animateSmartTargetMenu(hide: true)
			}
		})
	}

	func animateSmartTargetMenu(hide flag: Bool) {
		guard
			let bottomSmartTargetMenuConstraint = smartTargetMenuBottomLayoutConstraint,
			let smartTargetMenu = smartTargetMenu else { return }
		if flag { translationOfHideSmartTargetMenuOffset = nil }
		let factor: CGFloat = flag ? 1 : -1
		let offset = (translationOfHideSmartTargetMenuOffset ?? smartTargetMenu.frame.height / 2) * factor
		translationOfHideSmartTargetMenuOffset = offset
		let constant = bottomSmartTargetMenuConstraint.constant + offset

		smartTargetMenu.isEditable = (flag == false)
		smartTargetMenu.translucent(flag, value: 0.5)
		animateSmartTargetMenu(withBottomOffset: constant, layoutIfNeeded: true)
	}

	func animateMapViewFrame(withBottomOffset constant: CGFloat, layoutIfNeeded: Bool = true) {
		isAnimateMapView = true
		UIView.animate(withDuration: 0.5, animations: {
			self.mapViewBottomLayoutConstraint?.constant = constant
			self.view.layoutIfNeeded()
		}, completion: { _ in
			guard let pointer = self.currentPointer else { return }
			self.mapView.setCenter(pointer.coordinate, animated: true)
			self.isAnimateMapView = true
		})
	}

	func animateSmartTargetMenu(withBottomOffset constant: CGFloat, layoutIfNeeded: Bool = true) {
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
	func actionCurrentLocation() {
		showLocation(coordinate: mapView.userLocation.coordinate)
	}

	func actionCreateSmartTarget() {
		mode = .add
		isNewPointer = true
		addButtonView.isHidden = true
		mapView.selectedAnnotations
			.filter { $0 !== currentPointer }
			.forEach { mapView.deselectAnnotation($0, animated: true) }
		addTemptCircle(at: mapView.centerCoordinate, with: circleRadius)
		isEditSmartTarget = true
		interactor.temptSmartTarget = SmartTarget(title: "", coordinates: mapView.centerCoordinate)
		addCurrentPointer(at: mapView.centerCoordinate)
		showSmartTargetMenu()
		if regionIsChanging == false {
			interactor.getAddress(Map.Address.Request(coordinate: mapView.centerCoordinate))
			impactFeedbackGenerator.prepare()
		}
	}

	func actionSave(_ sender: Any) {

		var checkTitleText: Bool {
			guard let title = smartTargetMenu?.text else { return false }
			return title.isEmpty == false
		}

		guard
			let smartTargetMenu = smartTargetMenu,
			var temptSmartTarget = interactor.temptSmartTarget,
			let temptPointer = currentPointer else { return }

		guard checkTitleText else {
			smartTargetMenu.highlightTextField(true)
			smartTargetMenu.becomeFirstResponder()
			return
		}

		// Обновляем smart target
		temptSmartTarget.coordinates = temptPointer.coordinate
		temptSmartTarget.title = smartTargetMenu.text ?? "Noname"
		temptSmartTarget.address = smartTargetMenu.title
		temptSmartTarget.radius = Double(smartTargetMenu.sliderValue)

		// Обновляем данные посещаемости
		if temptLastPointer?.coordinate != temptPointer.coordinate {
			temptSmartTarget.setInitialAttendance()
		}
		if temptSmartTarget.region.contains(mapView.userLocation.coordinate) {
			temptSmartTarget.entryDate = Date()
		}
		else if temptSmartTarget.entryDate != nil {
			temptSmartTarget.exitDate = Date()
		}

		// Обновляем аннотацию (pin)
		temptPointer.title = smartTargetMenu.text

		// Меняем настройки для annotation view
		let annotationView = mapView.view(for: temptPointer)
		setAnnotationView(annotationView, draggable: false, andShowCallout: true)

		// Сохраняем smartTarget
		if temptLastPointer != nil {
			let request = Map.UpdateSmartTarget.Request(smartTarget: temptSmartTarget)
			interactor.updateSmartTarget(request)
		}
		else {
			let request = Map.AddSmartTarget.Request(smartTarget: temptSmartTarget)
			interactor.addSmartTarget(request)
		}

		// Начинаем отслеживание
		let monitoringRegionRequest = Map.StartMonitoringRegion.Request(smartTarget: temptSmartTarget)
		interactor.startMonitoringRegion(monitoringRegionRequest)

		smartTargetMenu.hide { smartTargetMenu.removeFromSuperview() }
		setupDefaultSettings()
	}

	func actionChooseActionForPin(_ sender: Any) {
		Alerts.showActionsForPinAlert(on: self, removeHandler: { [weak self] in
			self?.actionRemove(Any.self)
		}, cancelChangesHandler: { [weak self] in
			self?.actionCancelChanges(Any.self)
		}, cancelHandler: { [weak self] in
			self?.actionCancel(Any.self)
		})

		smartTargetMenu?.hide()
	}

	func actionRemove(_ sender: Any) {
		if removePinWithoutAlertRestricted && removePinAlertOn {
			Alerts.showDeletePinAlert(on: self) { [weak self] in
				if self?.mode == .edit, self?.smartTargetMenu?.leftMenuAction == self?.cancelAction {
					self?.actionChooseActionForPin(Any.self)
				}
			}
			removePinWithoutAlertRestricted = false
		}
		else {
			guard let temptPointer = currentPointer else { return }

			// Удаляем smartTarget
			let request = Map.RemoveSmartTarget.Request(uid: temptPointer.uid)
			interactor.removeSmartTarget(request)

			// Завершаем отслеживание
			let monitoringRegionRequest = Map.StopMonitoringRegion.Request(uid: temptPointer.uid)
			interactor.stopMonitoringRegion(monitoringRegionRequest)

			mapView.removeAnnotation(temptPointer)
			smartTargetMenu?.removeFromSuperview()
			setupDefaultSettings()
		}
	}

	func actionCancelChanges(_ sender: Any) {
		guard
			let temptPointer = currentPointer,
			let temptLastPointer = temptLastPointer else { return }

		// Меняем настройки для annotation view
		let annotationView = mapView.view(for: temptPointer)
		setAnnotationView(annotationView, draggable: false, andShowCallout: true)

		mapView.removeAnnotation(temptPointer)
		mapView.addAnnotation(temptLastPointer)

		smartTargetMenu?.removeFromSuperview()

		setupDefaultSettings()
	}

	func actionCancel(_ sender: Any) {
		smartTargetMenu?.show()
	}

	func actionChangeRadius(_ smartTargetMenu: SmartTargetMenu, radius: Float) {
		guard let temptPointer = currentPointer else { return }

		circleRadius = Double(radius)

		removeTemptCircle()
		addTemptCircle(at: temptPointer.coordinate, with: Double(radius))

		if temptLastPointer != nil, smartTargetMenu.leftMenuAction == removeAction {
			smartTargetMenu.leftMenuAction = cancelAction
		}
	}

	func actionChangeTitle(_ smartTargetMenu: SmartTargetMenu, text: String) {
		if temptLastPointer != nil, smartTargetMenu.leftMenuAction == removeAction {
			smartTargetMenu.leftMenuAction = cancelAction
		}
	}
}

// MARK: - Constraints
private extension MapViewController
{
	func setupMapConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapViewBottomLayoutConstraint = mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		mapViewBottomLayoutConstraint?.isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}

	func setupCurrentLocationButtonConstraints() {
		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
		currentLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
												   constant: Constants.Offset.mapButton).isActive = true
		currentLocationButton.heightAnchor.constraint(equalToConstant: Constants.Size.mapButton).isActive = true
		currentLocationButton.widthAnchor.constraint(equalToConstant: Constants.Size.mapButton).isActive = true
		currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
														constant: -Constants.Offset.mapButton).isActive = true
	}

	func setupAddButtonViewConstraints() {
		addButtonView.translatesAutoresizingMaskIntoConstraints = false

		addButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
												constant: -Constants.Offset.mapButton).isActive = true
		addButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
											  constant: -Constants.Offset.mapButton).isActive = true
		addButtonView.heightAnchor.constraint(equalToConstant: Constants.Size.mapButton).isActive = true
		addButtonView.widthAnchor.constraint(equalToConstant: Constants.Size.mapButton).isActive = true
	}

	func setupSmartTargetMenuConstraints() {
		smartTargetMenu?.translatesAutoresizingMaskIntoConstraints = false

		let tabBarHeight = (mode == .edit) ? (self.tabBarController?.tabBar.frame.height ?? 0) : 0

		smartTargetMenuBottomLayoutConstraint =
			smartTargetMenu?
				.bottomAnchor
				.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
							constant: -Constants.Offset.mapButton + tabBarHeight)
		smartTargetMenuBottomLayoutConstraint?.isActive = true

		smartTargetMenu?
			.leadingAnchor
			.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
			constant: Constants.Offset.mapButton).isActive = true

		smartTargetMenu?
			.trailingAnchor
			.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
						constant: -Constants.Offset.mapButton)
			.isActive = true
	}
}
