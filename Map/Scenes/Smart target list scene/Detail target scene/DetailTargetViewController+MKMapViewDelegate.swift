//
//  DetailTargetViewController+MKMapViewDelegate.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import MapKit

extension DetailTargetViewController
{

	func setupAnnotation() {
		let annotaion = presenter.getAnnotation()
		mapView.addAnnotation(annotaion)
		mapView.showAnnotations([annotaion], animated: false)
	}

	func setupOverlay() {
		let overlay = presenter.getDefaultCircleOverlay()
		mapView.removeOverlays(mapView.overlays)
		mapView.addOverlay(overlay)
	}

	func updateOverlay() {
		let overlay = presenter.getCircleOverlay()
		mapView.removeOverlays(mapView.overlays)
		mapView.addOverlay(overlay)
	}

	func setSmartTargetRegion(coordinate: CLLocationCoordinate2D,
							  camera: MKMapCamera? = nil,
							  animated: Bool) {
		if let camera = camera {
			camera.centerCoordinate = coordinate
			mapView.setCamera(camera, animated: animated)
		}
		else {
			let radius = presenter.editRadius * 4
			let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
			mapView.setRegion(region, animated: animated)
		}
	}
}

extension DetailTargetViewController: MKMapViewDelegate
{
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation { return nil }
		let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
		pinView.animatesDrop = false
		pinView.isDraggable = true
		pinView.canShowCallout = false
		return pinView
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKCircleRenderer(overlay: overlay)
		if #available(iOS 13.0, *) {
			renderer.fillColor = UIColor.systemBackground.withAlphaComponent(0.5)
		}
		else {
			renderer.fillColor = UIColor.white.withAlphaComponent(0.5)
		}
		renderer.strokeColor = .systemBlue
		renderer.lineWidth = 1
		return renderer
	}

	func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
		guard let overlay = mapView.overlays.first(where: { $0 is MKCircle }) else { return }
		let render = renderers.first { $0.overlay === overlay }
		render?.alpha = 0
		UIView.animate(withDuration: 0.3) {
			render?.alpha = 1
		}
	}

	func mapView(_ mapView: MKMapView,
				 annotationView view: MKAnnotationView,
				 didChange newState: MKAnnotationView.DragState,
				 fromOldState oldState: MKAnnotationView.DragState) {
		switch (oldState, newState) {
		case (.none, .starting): // 0 - 1
			mapView.removeOverlays(mapView.overlays)
		case (.starting, .dragging): // 1 - 2
			addressText = nil
		case (.dragging, .ending), // 2 - 4
			 (.dragging, .canceling), // 2 - 3
			 (.starting, .canceling), // 1 - 3
			 (.starting, .ending): // 1 - 4
			impactFeedbackGenerator.prepare()
			presenter.editCoordinate = view.annotation?.coordinate ?? presenter.editCoordinate
		case (.canceling, .none): // 3 - 0
			impactFeedbackGenerator.impactOccurred()
			updateOverlay()
		case (.ending, .none): // 4 - 0
			impactFeedbackGenerator.impactOccurred()
			setSmartTargetRegion(coordinate: presenter.editCoordinate, camera: mapView.camera, animated: true)
			presenter.getAddressText { self.addressText = $0 }
			updateOverlay()
		default: break
		}
	}
}
