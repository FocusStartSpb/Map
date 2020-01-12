//
//  DetailTargetRouter.swift
//  Map
//
//  Created by Anton on 30.12.2019.
//

import Foundation

protocol IDetailTargetRouter
{
	func dismissDetail()
	func saveChange()
	func popDetail()
	func attachViewController(detailTargetViewController: DetailTargetViewController)
}

final class DetailTargetRouter
{
	private weak var viewController: DetailTargetViewController?
}
// MARK: - IDetailTargetRouter()
extension DetailTargetRouter: IDetailTargetRouter
{
	@objc func dismissDetail() {
		viewController?.dismiss(animated: true, completion: nil)
	}

	func saveChange() {
		viewController?.navigationController?.popViewController(animated: true)
		return
	}

	func popDetail() {
		viewController?.navigationController?.popViewController(animated: true)
	}

	func attachViewController(detailTargetViewController: DetailTargetViewController) {
		self.viewController = detailTargetViewController
	}
}
