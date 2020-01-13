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
	func saveChanges(title: String?, coordinates: CLLocationCoordinate2D)
	func attachViewController(detailTargetViewController: DetailTargetViewController)
}

final class DetailTargetPresenter
{
	private let smartTarget: SmartTarget
	private let smartTargetCollection: ISmartTargetCollection
	private weak var viewController: DetailTargetViewController?

	init(smartTarget: SmartTarget,
		 smartTargetCollection: ISmartTargetCollection) {
		self.smartTarget = smartTarget
		self.smartTargetCollection = smartTargetCollection
	}

	private func dateFormatted(dateOfCreated: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss"
		let dateString = formatter.string(from: dateOfCreated)
		return dateString
	}
}

// MARK: - IDetailTargetInteractor
extension DetailTargetPresenter: IDetailTargetPresenter
{
	func getTitleText() -> String {
		return self.smartTarget.title
	}

	func getDateOfCreation() -> String {
		return dateFormatted(dateOfCreated: smartTarget.dateOfCreated)
	}

	func getAddressText() -> String {
		return "\("Address: \n" + (smartTarget.address ?? "not found"))"
	}

	func attachViewController(detailTargetViewController: DetailTargetViewController) {
		self.viewController = detailTargetViewController
	}

	func saveChanges(title: String?, coordinates: CLLocationCoordinate2D) {
		guard let title = title else { return }
		var modifiedTarget = self.smartTarget
		modifiedTarget.title = title
		if modifiedTarget.coordinates != coordinates {
			modifiedTarget.coordinates = coordinates
		}
		self.smartTargetCollection.replace(on: modifiedTarget)
	}
}
