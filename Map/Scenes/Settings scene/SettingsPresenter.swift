//
//  SettingsPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import Foundation

// MARK: - SettingsPresentationLogic protocol
protocol SettingsPresentationLogic
{
	func presentSegmentedControlItems(_ response: Settings.SegmentedControl.Response)
	func presentSwitchState(_ response: Settings.Switch.Response)
	func presentRangeSliderValues(_ response: Settings.RangeSlider.Response)
	func presentChangeValueSegmentedControl(_ response: Settings.ChangeValueSegmentedControl.Response)
	func presentChangeValueSwitch(_ response: Settings.ChangeValueSwitch.Response)
	func presentChangeValueSlider(_ response: Settings.ChangeValueRangeSlider.Response)
	func presentGetMeasurementSystem(_ response: Settings.GetMeasurementSystem.Response)
}

// MARK: - Class
final class SettingsPresenter
{
	// MARK: ...Internal properties
	weak var viewController: SettingsDisplayLogic?
}

// MARK: - Settings presentation logic protocol
extension SettingsPresenter: SettingsPresentationLogic
{
	func presentSegmentedControlItems(_ response: Settings.SegmentedControl.Response) {
		var title = ""
		var headerTitle = ""
		var footerTitle = ""
		switch response.typeItems {
		case .measurementSystem:
			headerTitle = "Система измерения"
			footerTitle = "Выбирете систему измерения: метрическую (м) или империческую (фт)"
		case .sorting:
			title = "Тип сортировки:"
			headerTitle = "Сортировка"
		default: break
		}
		let selectedItem = response.items.firstIndex { $0 == response.selectedItem } ?? 0
		let viewModel = Settings.SegmentedControl.ViewModel(title: title,
															headerTitle: headerTitle,
															footerTitle: footerTitle,
															typeItems: response.typeItems,
															items: response.items,
															selectedItem: selectedItem)
		viewController?.displaySegmentedControlItems(viewModel)
	}

	func presentSwitchState(_ response: Settings.Switch.Response) {
		var title = ""
		var headerTitle = ""
		var footerTitle = ""
		switch response.typeItems {
		case .forceRemovePin:
			title = "Включить предупреждения:"
			headerTitle = "Предупреждение при удалении локации"
			footerTitle = "Предупреждать при попытке удалить объект с карты или из таблицы"
		default: break
		}
		let viewModel = Settings.Switch.ViewModel(title: title,
												  headerTitle: headerTitle,
												  footerTitle: footerTitle,
												  typeItems: response.typeItems,
												  isOn: response.isOn)
		viewController?.displaySwitchState(viewModel)
	}

	func presentRangeSliderValues(_ response: Settings.RangeSlider.Response) {
		let title = ""
		var headerTitle = ""
		var footerTitle = ""
		switch response.typeItems {
		case .minRangeOfRadius:
			headerTitle = "Пределы радиуса"
			footerTitle = "Установите значения минимально и максимально допустимой установки радиуса "
		default: break
		}
		let viewModel = Settings.RangeSlider.ViewModel(title: title,
													   headerTitle: headerTitle,
													   footerTitle: footerTitle,
													   typeItems: response.typeItems,
													   range: response.range,
													   rangeValues: response.rangeValues,
													   userValues: response.userValues)
		viewController?.displayRangeSliderValues(viewModel)
	}

	func presentChangeValueSegmentedControl(_ response: Settings.ChangeValueSegmentedControl.Response) {
		DispatchQueue.main.async { [weak self] in
			let viewModel = Settings.ChangeValueSegmentedControl.ViewModel(isChanged: response.isChanged,
																		   typeItems: response.typeItems)
			self?.viewController?.displayChangeValueSegmentedControl(viewModel)
		}
	}

	func presentChangeValueSwitch(_ response: Settings.ChangeValueSwitch.Response) {
		DispatchQueue.main.async { [weak self] in
			let viewModel = Settings.ChangeValueSwitch.ViewModel(isChanged: response.isChanged, typeItems: response.typeItems)
			self?.viewController?.displayChangeValueSwitch(viewModel)
		}
	}

	func presentChangeValueSlider(_ response: Settings.ChangeValueRangeSlider.Response) {
		DispatchQueue.main.async { [weak self] in
			let viewModel = Settings.ChangeValueRangeSlider.ViewModel(isChanged: response.isChanged,
																	  typeItems: response.typeItems)
			self?.viewController?.displayChangeValueSlider(viewModel)
		}
	}

	func presentGetMeasurementSystem(_ response: Settings.GetMeasurementSystem.Response) {
		let symbol = response.measurementSystem.symbol
		let factor = response.measurementSystem.factor
		let viewModel = Settings.GetMeasurementSystem.ViewModel(measurementSymbol: symbol,
															  measurementFactor: factor)
		viewController?.displayGetMeasurementSystem(viewModel)
	}
}
