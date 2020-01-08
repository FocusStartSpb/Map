//
//  DetailTargetInteractor.swift
//  Map
//
//  Created by Антон on 30.12.2019.
//

import Foundation

protocol IDetailTargetPresenter
{
	func getTarget()
	func getTitleText() -> String
	func getAddressText() -> String
	func getDateOfCreation() -> String
}

final class DetailTargetPresenter
{
	private let smartTarget: SmartTarget

	init(smartTarget: SmartTarget) {
		self.smartTarget = smartTarget
	}
}

// MARK: - IDetailTargetInteractor
extension DetailTargetPresenter: IDetailTargetPresenter
{
	func getTitleText() -> String {
		return self.smartTarget.title
	}

	func getTarget() {
		print("Below will be a test print")
	}

	func getDateOfCreation() -> String {
		return "Date of creation \n 01.01.2020" //ну тип заглушка
	}

	func getAddressText() -> String {
		return "\("Address: \n" + (smartTarget.address ?? "not found"))"
	}
}
