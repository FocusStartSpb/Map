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

	func getTitleText() -> String
	func getAddressText(completion: @escaping (String) -> Void)
	func getDateOfCreation() -> String
	func getAnnotation() -> SmartTargetAnnotation
	func getCircleOverlay() -> MKCircle
	func saveChanges(title: String?, coordinates: CLLocationCoordinate2D) -> SmartTarget
	func attachViewController(detailTargetViewController: DetailTargetViewController)
}

final class DetailTargetPresenter<G: IDecoderGeocoder>
{
	private let smartTarget: SmartTarget

	var editRadius: CLLocationDistance
	var editCoordinate: CLLocationCoordinate2D

	private weak var viewController: DetailTargetViewController?
	private var geocoderWorker: GeocoderWorker<G>

	private let dispatchQueueGetAddress =
	DispatchQueue(label: "com.detailTarget.getAddress",
				  qos: .userInitiated,
				  attributes: .concurrent)

	init(smartTarget: SmartTarget,
		 geocoderWorker: GeocoderWorker<G>) {
		self.smartTarget = smartTarget
		self.geocoderWorker = geocoderWorker
		self.editRadius = smartTarget.radius ?? 0
		self.editCoordinate = smartTarget.coordinates
	}
}

// MARK: - IDetailTargetInteractor
extension DetailTargetPresenter: IDetailTargetPresenter
{
	func getTitleText() -> String {
		return self.smartTarget.title
	}

	func getDateOfCreation() -> String {
		return Formatter.full.string(from: smartTarget.dateOfCreated)
	}

	func getAddressText(completion: @escaping (String) -> Void) {
		dispatchQueueGetAddress.async { [weak self] in
			guard let self = self else { return }
			self.geocoderWorker.getGeocoderMetaData(by: self.editCoordinate.geocode) { result in
				let result = result
					.map { $0.response?.geoCollection?.featureMember?.first?.geo?.metaDataProperty?.geocoderMetaData?.text ?? "" }
				var address: String = "Address: \n"
				if case .success(let string) = result {
					address += string
				}
				else {
					address += "\(self.editCoordinate)"
				}

				DispatchQueue.main.async {
					completion(address)
				}
			}
		}
	}

	func getAnnotation() -> SmartTargetAnnotation {
		return smartTarget.annotation
	}

	func getCircleOverlay() -> MKCircle {
		return MKCircle(center: editCoordinate, radius: editRadius)
	}

	func attachViewController(detailTargetViewController: DetailTargetViewController) {
		self.viewController = detailTargetViewController
	}

	func saveChanges(title: String?, coordinates: CLLocationCoordinate2D) -> SmartTarget {
		let title = title ?? ""
		var modifiedTarget = self.smartTarget
		modifiedTarget.title = title
//		if modifiedTarget.coordinates != coordinates {
//			modifiedTarget.coordinates = coordinates
//		}
		self.smartTargetCollection.put(modifiedTarget)
		return modifiedTarget
	}
}
