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
	func displaySmartTargets(_ viewModel: Map.FetchSmartTargets.ViewModel)
	func displaySmartTarget(_ viewModel: Map.GetSmartTarget.ViewModel)
	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel)
	func displayAddress(_ viewModel: Map.Address.ViewModel)

	// Adding, updating, removing smart targets
	func displayAddSmartTarget(_ viewModel: Map.AddSmartTarget.ViewModel)
	func displayRemoveSmartTarget(_ viewModel: Map.RemoveSmartTarget.ViewModel)
	func displayUpdateSmartTarget(_ viewModel: Map.UpdateSmartTarget.ViewModel)

	func displayUpdateSmartTargets(_ viewModel: Map.UpdateSmartTargets.ViewModel)

	// Notifications
	func displaySetNotificationServiceDelegate(_ viewModel: Map.SetNotificationServiceDelegate.ViewModel)

	// Monitoring Region
	func displayStartMonitoringRegion(_ viewModel: Map.StartMonitoringRegion.ViewModel)
	func displayStopMonitoringRegion(_ viewModel: Map.StopMonitoringRegion.ViewModel)

	// Settings
	func displayGetCurrentRadius(_ viewModel: Map.GetCurrentRadius.ViewModel)
	func displayGetRangeRadius(_ viewModel: Map.GetRangeRadius.ViewModel)
	func displayGetMeasuringSystem(_ viewModel: Map.GetMeasuringSystem.ViewModel)
	func displayGetRemovePinAlertSettings(_ viewModel: Map.GetRemovePinAlertSettings.ViewModel)
}

// MARK: - Class
final class MapViewController: UIViewController
{
	private enum Mode
	{
		case edit, add, none
	}
	// MARK: ...Private properties
	private var interactor: MapBusinessLogic & MapDataStore
	let router: MapRoutingLogic & MapDataPassing

	// UI elements
	private let impactFeedbackGenerator: UIImpactFeedbackGenerator = {
		if #available(iOS 13.0, *) {
			return UIImpactFeedbackGenerator(style: .soft)
		}
		else {
			return UIImpactFeedbackGenerator(style: .light)
		}
	}()

	private lazy var mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.showsCompass = false
		mapView.delegate = self
		return mapView
	}()

	private lazy var currentLocationButton: ButtonView = {
		let view = ButtonView(type: .currentLocation, tapAction: actionCurrentLocation)
		view.isHidden = true
		return view
	}()
	private lazy var addButtonView = ButtonView(type: .add, tapAction: actionCreateSmartTarget)

	private var smartTargetMenu: SmartTargetMenu?

	// Tempt annotation
	private var currentPointer: SmartTargetAnnotation?
	private var temptLastPointer: SmartTargetAnnotation?
	// Tempt overlay
	private var temptCircle: MKCircle?

	private lazy var saveAction = MenuAction(title: "Save", style: .default, handler: actionSave)
	private lazy var removeAction = MenuAction(title: "Remove", style: .destructive, handler: actionRemove)
	private lazy var cancelAction = MenuAction(title: "Cancel", style: .cancel, handler: actionChooseActionForPin)

	// Editing properties
	private var mode: Mode = .none
	private var isEditSmartTarget = false
	private var isDraggedTemptPointer = false
	private var isNewPointer = false
	private var isAnimateMapView = false
	private var isAnimateSmartTargetMenu = false
	private var willTranslateKeyboard = false
	private var regionIsChanging = false
	private var circleRadius = 300.0
	private var removePinWithoutAlertRestricted = true
	private var removePinAlertOn = true

	// Calculated properties
	private var annotations: [SmartTargetAnnotation] {
		mapView
			.annotations
			.filter { $0 is SmartTargetAnnotation }
			.compactMap { $0 as? SmartTargetAnnotation }
	}

	// Constants
	private let latitudalMeters = 5_000.0
	private let longtitudalMeters = 5_000.0
	private let currentLocationButtonSize: CGFloat = 40.0
	private let offset: CGFloat = 20.0

	// Constraints of smart target menu
	private var smartTargetMenuBottomLayoutConstraint: NSLayoutConstraint?

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

		// Add notifications
		notificationCenter.addObserver(self, notifications: applicationNotifications)

		// Send Requests
		interactor.updateSmartTargets(.init())
		interactor.getMeasuringSystem(.init())
		interactor.getRemovePinAlertSettings(.init())
		removePinWithoutAlertRestricted = true
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Remove notifications
		notificationCenter.removeObserver(self, names: Set(applicationNotifications.keys))
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
		let fetchSmartTardetRequest = Map.FetchSmartTargets.Request()
		interactor.getSmartTargets(fetchSmartTardetRequest)

		let notificationRequest = Map.SetNotificationServiceDelegate.Request(notificationDelegate: self)
		interactor.setNotificationServiceDelegate(notificationRequest)

		let request = Map.GetCurrentRadius.Request(currentRadius: circleRadius)
		interactor.getCurrentRadius(request)
	}

	private func setAnnotationView(_ annotationView: MKAnnotationView?,
								   draggable: Bool,
								   andShowCallout canShowCallout: Bool) {
		annotationView?.isDraggable = draggable
		annotationView?.canShowCallout = canShowCallout
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

	// MARK: ...Map methods
	private func showLocation(coordinate: CLLocationCoordinate2D) {
		let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.latitudalMeters,
											longitudinalMeters: self.longtitudalMeters)
		mapView.setRegion(zoomRegion, animated: true)
	}

	private func addCurrentPointer(at coordinate: CLLocationCoordinate2D) {
		guard let target = interactor.temptSmartTarget else { return }
		let annotation = SmartTargetAnnotation(uid: target.uid,
											   title: target.title,
											   coordinate: coordinate)
		mapView.addAnnotation(annotation)
		currentPointer = annotation
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

	// MARK: ...Menu methods
	private func createSmartTargetMenu() -> SmartTargetMenu {
		SmartTargetMenu(textField: interactor.temptSmartTarget?.title,
						sliderValue: interactor.temptSmartTarget?.radius ?? circleRadius,
						sliderValuesRange: (50, 1000),
						title: interactor.temptSmartTarget?.address,
						leftAction: removeAction,
						rightAction: saveAction,
						sliderAction: actionChangeRadius,
						textFieldAction: actionChangeTitle)
	}

	private func showSmartTargetMenu() {
		let menu = createSmartTargetMenu()
		smartTargetMenu = menu

		interactor.getRangeRadius(.init())
		interactor.getCurrentRadius(.init(currentRadius: circleRadius))
		interactor.getMeasuringSystem(.init())

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

	private func animateSmartTargetMenu(hide flag: Bool) {
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

	private func animateMapViewFrame(withBottomOffset constant: CGFloat, layoutIfNeeded: Bool = true) {
		isAnimateMapView = true
		UIView.animate(withDuration: 0.5, animations: {
			self.mapViewBottomLayoutConstraint?.constant = constant
			if layoutIfNeeded {
				self.view.layoutIfNeeded()
			}
		}, completion: { _ in
			guard let pointer = self.currentPointer else { return }
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

	private func animatePinViewHidden(_ isHidden: Bool) {
		if let temptPointer = currentPointer, let view = mapView.view(for: temptPointer) {
			UIView.animate(withDuration: 0.25, delay: 0.25, animations: {
				view.alpha = isHidden ? 0 : 1
			}, completion: { _ in
				view.isHidden = isHidden
			})
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

	func actionEditSmartTarget(annotation: SmartTargetAnnotation) {
		mode = .edit
		setTabBarVisible(false)
		let request = Map.GetSmartTarget.Request(uid: annotation.uid)
		interactor.getSmartTarget(request)
		addButtonView.isHidden = true
		if currentPointer?.coordinate == mapView.centerCoordinate {
			isEditSmartTarget = true
		}
		addTemptCircle(at: annotation.coordinate,
					   with: interactor.temptSmartTarget?.radius ?? circleRadius)
		temptLastPointer = currentPointer?.copy()
		showSmartTargetMenu()
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
				if self?.mode == .edit, self?.smartTargetMenu?.leftMenuAction.title == "Cancel" {
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
		smartTargetMenuBottomConstant = -keyboardHeight / 3
		animateSmartTargetMenu(withBottomOffset: smartTargetMenuBottomConstant)
	}

	func keyboardWillDisappear(notification: NSNotification?) {
		willTranslateKeyboard = true
		let tabBarHeight = tabBarIsVisible ? 0 : tabBarController?.tabBar.frame.height ?? 0
		animateMapViewFrame(withBottomOffset: 0, layoutIfNeeded: false)
		smartTargetMenuBottomConstant = -offset + tabBarHeight
		animateSmartTargetMenu(withBottomOffset: smartTargetMenuBottomConstant, layoutIfNeeded: false)
	}

	func keyboardDidAppear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func keyboardDidDisappear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func appMovedFromBackground() {
		let updateStatusRequest = Map.UpdateStatus.Request()
		interactor.configureLocationService(request: updateStatusRequest)

		notificationCenter.addObserver(self, notifications: keyboardNotifications)
		if currentPointer != nil {
			smartTargetMenu?.translucent(false)
			smartTargetMenu?.isEditable = true
		}

		if mode == .edit {
			setTabBarVisible(false, duration: 0)
		}
	}

	func appMovedToBackground() {
		notificationCenter.removeObserver(self, names: Set(keyboardNotifications.keys))
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
													  constant: offset).isActive = true
		currentLocationButton.heightAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
		currentLocationButton.widthAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
		currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
														constant: -offset).isActive = true
	}

	func setupAddButtonViewConstraints() {
		addButtonView.translatesAutoresizingMaskIntoConstraints = false

		addButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
												constant: -offset).isActive = true
		addButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
											  constant: -offset).isActive = true
		addButtonView.heightAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
		addButtonView.widthAnchor.constraint(equalToConstant: currentLocationButtonSize).isActive = true
	}

	func setupSmartTargetMenuConstraints() {
		smartTargetMenu?.translatesAutoresizingMaskIntoConstraints = false

		let tabBarHeight = (mode == .edit) ? (self.tabBarController?.tabBar.frame.height ?? 0) : 0

		smartTargetMenuBottomLayoutConstraint =
			smartTargetMenu?
				.bottomAnchor
				.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
							constant: -offset + tabBarHeight)
		smartTargetMenuBottomLayoutConstraint?.isActive = true

		smartTargetMenu?
			.leadingAnchor
			.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
			constant: offset).isActive = true

		smartTargetMenu?
			.trailingAnchor
			.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
						constant: -offset)
			.isActive = true
	}
}

// MARK: - Map display logic
extension MapViewController: MapDisplayLogic
{

	func displaySmartTargets(_ viewModel: Map.FetchSmartTargets.ViewModel) {
		mapView.addAnnotations(viewModel.annotations)
	}

	func displaySmartTarget(_ viewModel: Map.GetSmartTarget.ViewModel) {
		interactor.temptSmartTarget = viewModel.smartTarget
	}

	func showLocationUpdates(viewModel: Map.UpdateStatus.ViewModel) {
		if viewModel.isShownUserPosition, mapView.showsUserLocation == false, let coordinate = viewModel.userCoordinate {
			showLocation(coordinate: coordinate)
		}
		mapView.showsUserLocation = viewModel.isShownUserPosition
		currentLocationButton.isHidden = (viewModel.isShownUserPosition == false)
	}

	func displayAddress(_ viewModel: Map.Address.ViewModel) {
		smartTargetMenu?.title = viewModel.address
	}

	func displayAddSmartTarget(_ viewModel: Map.AddSmartTarget.ViewModel) { }

	func displayRemoveSmartTarget(_ viewModel: Map.RemoveSmartTarget.ViewModel) { }

	func displaySetNotificationServiceDelegate(_ viewModel: Map.SetNotificationServiceDelegate.ViewModel) { }

	func displayStartMonitoringRegion(_ viewModel: Map.StartMonitoringRegion.ViewModel) { }

	func displayStopMonitoringRegion(_ viewModel: Map.StopMonitoringRegion.ViewModel) { }

	func displayUpdateSmartTarget(_ viewModel: Map.UpdateSmartTarget.ViewModel) { }

	func displayUpdateSmartTargets(_ viewModel: Map.UpdateSmartTargets.ViewModel) {
		let removedAnnotations = annotations.filter {
			viewModel.removedUIDs.contains($0.uid) || viewModel.updatedUIDs.contains($0.uid)
		}
		let addedAnnotations = annotations.filter {
			viewModel.addedUIDs.contains($0.uid) || viewModel.updatedUIDs.contains($0.uid)
		}

		mapView.removeAnnotations(removedAnnotations)
		mapView.addAnnotations(addedAnnotations)
	}

	func displayGetCurrentRadius(_ viewModel: Map.GetCurrentRadius.ViewModel) {
		if temptLastPointer == nil {
			circleRadius = viewModel.radius
			smartTargetMenu?.sliderValue = Float(circleRadius)
		}
	}

	func displayGetRangeRadius(_ viewModel: Map.GetRangeRadius.ViewModel) {
		smartTargetMenu?.sliderValuesRange = (viewModel.userValues.lower, viewModel.userValues.upper)
		if
			let menu = smartTargetMenu,
			let smartTarget = interactor.temptSmartTarget,
			temptLastPointer != nil {
			menu.sliderValuesRange = (min(menu.sliderValuesRange.min, circleRadius),
									  max(menu.sliderValuesRange.max, circleRadius))
			menu.sliderValue = Float(smartTarget.radius ?? menu.sliderValuesRange.min)
		}
	}

	func displayGetMeasuringSystem(_ viewModel: Map.GetMeasuringSystem.ViewModel) {
		smartTargetMenu?.sliderFactor = Float(viewModel.measuringFactor)
		smartTargetMenu?.sliderValueMeasuringSymbol = viewModel.measuringSymbol
	}

	func displayGetRemovePinAlertSettings(_ viewModel: Map.GetRemovePinAlertSettings.ViewModel) {
		removePinAlertOn = viewModel.removePinAlertOn
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
		}
		else {
			pinView?.annotation = annotation
		}
		pinView?.animatesDrop = isNewPointer
		pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		setAnnotationView(pinView, draggable: isEditSmartTarget, andShowCallout: (isEditSmartTarget == false))

		if let currentPointer = currentPointer, annotation !== currentPointer {
			pinView?.isHidden = false
			pinView?.alpha = 1
			pinView?.canShowCallout = true
		}

		if isNewPointer {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
				if self?.regionIsChanging == false {
					self?.impactFeedbackGenerator.impactOccurred()
				}
			}
			isNewPointer = false
		}

		return pinView
	}

	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		regionIsChanging = true
		guard willTranslateKeyboard == false, isDraggedTemptPointer == false else { return }
		if isAnimateSmartTargetMenu == false {
			animateSmartTargetMenu(hide: true)
		}
		smartTargetMenu?.title = nil
		if temptLastPointer != nil {
			smartTargetMenu?.leftMenuAction = self.cancelAction
		}
		animatePinViewHidden(true)
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		guard let temptPointer = currentPointer, isEditSmartTarget,
			isDraggedTemptPointer == false,
			isAnimateMapView == false else { return }

		smartTargetMenu?.title = nil

		// Update pointer annotation
		mapView.removeAnnotation(temptPointer)
		addCurrentPointer(at: mapView.centerCoordinate)

		// Update circe overlay
		removeTemptCircle()
		addTemptCircle(at: mapView.centerCoordinate, with: circleRadius)
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		regionIsChanging = false
		guard let temptPointer = self.currentPointer,
			isAnimateMapView == false,
			isDraggedTemptPointer == false else {
				isAnimateMapView = false
				isDraggedTemptPointer = false
				return
		}
		guard isEditSmartTarget else {
			isEditSmartTarget = true
			return
		}
		if willTranslateKeyboard == false {
			if isAnimateSmartTargetMenu == false {
				animateSmartTargetMenu(hide: false)
			}
		}
		removePinWithoutAlertRestricted = true
		animatePinViewHidden(false)
		interactor.getAddress(Map.Address.Request(coordinate: temptPointer.coordinate))
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
			smartTargetMenu?.title = nil
		case (.dragging, .ending), // 2 - 4
			 (.dragging, .canceling), // 2 - 3
			 (.starting, .canceling), // 1 - 3
			 (.starting, .ending): // 1 - 4
			impactFeedbackGenerator.prepare()
		case (.canceling, .none): // 3 - 0
			impactFeedbackGenerator.impactOccurred()
			guard let temptPointer = currentPointer else { return }
			animateSmartTargetMenu(hide: false)
			addTemptCircle(at: temptPointer.coordinate, with: circleRadius)
		case (.ending, .none): // 4 - 0
			impactFeedbackGenerator.impactOccurred()
			guard let temptPointer = currentPointer else { return }
			showLocation(coordinate: temptPointer.coordinate)
			animateSmartTargetMenu(hide: false)
			interactor.getAddress(Map.Address.Request(coordinate: mapView.centerCoordinate))
			addTemptCircle(at: temptPointer.coordinate, with: circleRadius)
			if temptLastPointer != nil {
				smartTargetMenu?.leftMenuAction = cancelAction
			}
			removePinWithoutAlertRestricted = true
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

	func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
		guard
			let overlay = temptCircle,
			(isEditSmartTarget == false && currentPointer == nil ) ||
			(isEditSmartTarget && isDraggedTemptPointer) else { return }
		let render = renderers.first { $0.overlay === overlay }
		render?.alpha = 0
		UIView.animate(withDuration: 0.3) {
			render?.alpha = 1
		}
	}

	func mapView(_ mapView: MKMapView,
				 annotationView view: MKAnnotationView,
				 calloutAccessoryControlTapped control: UIControl) {
		guard let annotation = view.annotation as? SmartTargetAnnotation else { return }
		isNewPointer = false
		showLocation(coordinate: annotation.coordinate)
		mapView.deselectAnnotation(view.annotation, animated: true)
		setAnnotationView(view, draggable: true, andShowCallout: false)
		currentPointer = annotation
		actionEditSmartTarget(annotation: annotation)
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if isEditSmartTarget == false, let annotation = (view.annotation as? SmartTargetAnnotation) {
			let request = Map.GetSmartTarget.Request(uid: annotation.uid)
			interactor.getSmartTarget(request)
			if let radius = interactor.temptSmartTarget?.radius {
				// Update radius
				circleRadius = radius
				// Add overlay
				addTemptCircle(at: annotation.coordinate, with: radius)
			}
			interactor.temptSmartTarget = nil
		}
		else if isEditSmartTarget && view.annotation !== currentPointer {
			mapView.deselectAnnotation(view.annotation, animated: false)
		}
	}

	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		if isEditSmartTarget == false, view.annotation !== currentPointer {
			removeTemptCircle()
		}
	}
}

// MARK: - Notification service delegate
extension MapViewController: NotificationServiceDelegate
{
	func notificationService(_ notificationService: NotificationService,
							 action: NotificationService.Action,
							 forUID uid: String,
							 atNotificationDeliveryDate deliveryDate: Date) {
		switch action {
		case .show:
			guard let annotation = annotations.first(where: { $0.uid == uid }) else { return }
			showLocation(coordinate: annotation.coordinate)
			mapView.selectAnnotation(annotation, animated: true)
		case .dismiss: break
		case .cancel: break
		case .default: break
		}
	}

	func notificationService(_ notificationService: NotificationService,
							 didReceiveNotificationForUID uid: String,
							 atNotificationDeliveryDate deliveryDate: Date) {
	}
}

// MARK: - Tab bar controller delegate
extension MapViewController: UITabBarControllerDelegate
{
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		tabBarController.delegate = nil
		guard let navigationController = viewController as? UINavigationController else {
			return true
		}
		guard let tableListController = navigationController.viewControllers.first as? SmartTargetListViewController
			else { return true }
		router.routeToSmartTargetList(tableListController)
		return false
	}
}
