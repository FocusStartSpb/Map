//
//  DetailTargetRouter.swift
//  Map
//
//  Created by Anton on 30.12.2019.
//

import Foundation

protocol IDetailTargetRouter
{
	func saveChange()
	func popDetail(to destination: SmartTargetListViewController, smartTarget: SmartTarget)
	func attachViewController(detailTargetViewController: DetailTargetViewController)
}

final class DetailTargetRouter
{
	private weak var detailViewController: DetailTargetViewController?
}
// MARK: - IDetailTargetRouter()
extension DetailTargetRouter: IDetailTargetRouter
{
	func saveChange() {
		detailViewController?.navigationController?.popViewController(animated: true)
		return
	}

	func popDetail(to destination: SmartTargetListViewController, smartTarget: SmartTarget) {
		destination.router.dataStore?.editedSmartTarget = smartTarget
		detailViewController?.navigationController?.popToViewController(destination, animated: true)
	}

	func attachViewController(detailTargetViewController: DetailTargetViewController) {
		self.detailViewController = detailTargetViewController
	}
}
