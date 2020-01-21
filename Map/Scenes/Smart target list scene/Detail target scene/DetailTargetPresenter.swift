//
//  DetailTargetInteractor.swift
//  Map
//
//  Created by Антон on 30.12.2019.
//

import MapKit

protocol IDetailTargetPresenter
{
	var editRadius: CLLocationDegrees { get set }
	var editCoordinate: CLLocationCoordinate2D { get set }
	var totalNumberOfVisits: String { get }
	var totalStay: String { get }
	var dateOfLastVisit: String { get }

	func setupInitialData()

	func getTitleText() -> String
	func getRadius() -> Double
	func getAddressText(completion: @escaping (String) -> Void)
	func getDateOfCreation() -> String
	func getAnnotation() -> SmartTargetAnnotation
	func getDefaultCircleOverlay() -> MKCircle
	func getCircleOverlay() -> MKCircle
	func saveChanges(title: String?, address: String?) -> SmartTarget
	func attachViewController(detailTargetViewController: DetailTargetViewController)

	func getSliderValuesRange() -> (min: Double, max: Double)
	func getMeasurementSystem() -> UserPreferences.MeasurementSystem
}

final class DetailTargetPresenter<G: IDecoderGeocoder>
{
	private let smartTarget: SmartTarget
	private let separator = ":"

	var editRadius: CLLocationDistance
	var editCoordinate: CLLocationCoordinate2D

	private weak var viewController: DetailTargetViewController?
	private var geocoderWorker: GeocoderWorker<G>
	private var settingsWorker: SettingsWorker

	private let dispatchQueueGetAddress =
	DispatchQueue(label: "com.detailTarget.getAddress",
				  qos: .userInitiated,
				  attributes: .concurrent)

	init(smartTarget: SmartTarget,
		 geocoderWorker: GeocoderWorker<G>,
		 settingsWorker: SettingsWorker) {
		self.smartTarget = smartTarget
		self.geocoderWorker = geocoderWorker
		self.settingsWorker = settingsWorker
		self.editRadius = smartTarget.radius ?? 0
		self.editCoordinate = smartTarget.coordinates
	}
}

// MARK: - IDetailTargetInteractor
extension DetailTargetPresenter: IDetailTargetPresenter
{
	var totalNumberOfVisits: String {
		self.smartTarget.numberOfVisits.description
	}

	var totalStay: String {
		self.smartTarget.timeInside.string
	}

	var dateOfLastVisit: String {
		guard let exitDate = smartTarget.exitDate else { return "" }
		let formatter = DateFormatter.full
		let dateString = formatter.string(from: exitDate)
		return dateString
	}

	func setupInitialData() {
		editRadius = smartTarget.radius ?? editRadius
		editCoordinate = smartTarget.coordinates
	}

	func getTitleText() -> String {
		self.smartTarget.title
	}

	func getRadius() -> Double {
		self.smartTarget.radius ?? 0
	}

	func getDateOfCreation() -> String {
		Formatter.full.string(from: smartTarget.dateOfCreated)
	}

	func getAddressText(completion: @escaping (String) -> Void) {
		dispatchQueueGetAddress.async { [weak self] in
			guard let self = self else { return }
			self.geocoderWorker.getGeocoderMetaData(by: self.editCoordinate.geocode) { result in
				let result = result
					.map { $0.response?.geoCollection?.featureMember?.first?.geo?.metaDataProperty?.geocoderMetaData?.text ?? "" }
				let address: String
				if case .success(let string) = result {
					address = string
				}
				else {
					address = "\(self.editCoordinate)"
				}

				DispatchQueue.main.async {
					completion(address)
				}
			}
		}
	}

	func getAnnotation() -> SmartTargetAnnotation {
		smartTarget.annotation
	}

	func getDefaultCircleOverlay() -> MKCircle {
		MKCircle(center: smartTarget.coordinates, radius: smartTarget.radius ?? 0)
	}

	func getCircleOverlay() -> MKCircle {
		MKCircle(center: editCoordinate, radius: editRadius)
	}

	func attachViewController(detailTargetViewController: DetailTargetViewController) {
		self.viewController = detailTargetViewController
	}

	func saveChanges(title: String?, address: String?) -> SmartTarget {
		let title = title ?? ""
		var modifiedTarget = self.smartTarget
		modifiedTarget.title = title
		modifiedTarget.coordinates = editCoordinate
		modifiedTarget.radius = editRadius
		modifiedTarget.address = address
		return modifiedTarget
	}

	func getSliderValuesRange() -> (min: Double, max: Double) {
		(settingsWorker.lowerValueOfRadius ?? 0, settingsWorker.upperValueOfRadius ?? 1)
	}

	func getMeasurementSystem() -> UserPreferences.MeasurementSystem {
		settingsWorker.measurementSystem ?? .metric
	}
}
