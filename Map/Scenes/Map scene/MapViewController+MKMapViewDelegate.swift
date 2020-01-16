//
//  MapViewController+MKMapViewDelegate.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import MapKit

extension MapViewController
{
	func showLocation(coordinate: CLLocationCoordinate2D) {
		let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: Constants.Distance.latitudalMeters,
											longitudinalMeters: Constants.Distance.longtitudalMeters)
		mapView.setRegion(zoomRegion, animated: true)
	}

	func setRegion(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, animated: Bool) {
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius * 4, longitudinalMeters: radius * 4)
		mapView.setRegion(region, animated: animated)
	}
}

// MARK: - Animations
extension MapViewController
{
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
extension MapViewController
{
	private func actionEditSmartTarget(annotation: SmartTargetAnnotation) {
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
			smartTargetMenu?.leftMenuAction = cancelAction
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
			mapView.setCenter(temptPointer.coordinate, animated: true)
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
		setRegion(coordinate: annotation.coordinate, radius: circleRadius, animated: true)
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
