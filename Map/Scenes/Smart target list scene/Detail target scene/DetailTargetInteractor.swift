//
//  DetailTargetInteractor.swift
//  Map
//
//  Created by Антон on 30.12.2019.
//

import Foundation

protocol IDetailTargetInteractor
{
	func getTarget()
	func getTitleText() -> String
	func getAddressText() -> String
	func getDateOfCreation() -> String
}

final class DetailTargetInteractor
{
	private let detailPresenter: DetailTargetPresenter
	private let smartTarget: SmartTarget

	init(detailPresenter: DetailTargetPresenter,
		 smartTarget: SmartTarget) {
		self.detailPresenter = detailPresenter
		self.smartTarget = smartTarget
	}
}

// MARK: - IDetailTargetInteractor
extension DetailTargetInteractor: IDetailTargetInteractor
{
	func getTarget() {
		print("Below will be a test print")
	}

	func getTitleText() -> String {
		return smartTarget.title
	}

	func getDateOfCreation() -> String {
		return "Date of creation \n 01.01.2020" //ну тип заглушка
	}

	func getAddressText() -> String {
		return "\("Address: \n" + (smartTarget.address ?? "not found"))"
	}
}
