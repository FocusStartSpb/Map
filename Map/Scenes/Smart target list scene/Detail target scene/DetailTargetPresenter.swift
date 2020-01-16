//
//  DetailTargetInteractor.swift
//  Map
//
//  Created by Антон on 30.12.2019.
//

import Foundation
import CoreLocation

protocol IDetailTargetPresenter
{
	func getTitleText() -> String
	func getAddressText() -> String
	func getDateOfCreation() -> String
	func saveChanges(title: String?, coordinates: CLLocationCoordinate2D) -> SmartTarget
	func attachViewController(detailTargetViewController: DetailTargetViewController)
}

final class DetailTargetPresenter<G: IDecoderGeocoder>
{
	private let smartTarget: SmartTarget
	private let smartTargetCollection: ISmartTargetCollection
	private weak var viewController: DetailTargetViewController?
	private var geocoderWorker: GeocoderWorker<G>

	init(smartTarget: SmartTarget,
		 smartTargetCollection: ISmartTargetCollection,
		 geocoderWorker: GeocoderWorker<G>) {
		self.smartTarget = smartTarget
		self.smartTargetCollection = smartTargetCollection
		self.geocoderWorker = geocoderWorker
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

	func getAddressText() -> String {
		return "\("Address: \n" + (smartTarget.address ?? "not found"))"
	}

	func attachViewController(detailTargetViewController: DetailTargetViewController) {
		self.viewController = detailTargetViewController
	}

	func saveChanges(title: String?, coordinates: CLLocationCoordinate2D) -> SmartTarget {
		let title = title ?? ""
		var modifiedTarget = self.smartTarget
		modifiedTarget.title = title
		if modifiedTarget.coordinates != coordinates {
			modifiedTarget.coordinates = coordinates
		}
		self.smartTargetCollection.put(modifiedTarget)
		return modifiedTarget
	}
}
