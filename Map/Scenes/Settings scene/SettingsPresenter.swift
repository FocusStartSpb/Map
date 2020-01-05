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
		switch response.typeItems {
		case .measuringSystem: title = "Measuring System:"
		case .sorting: title = "Sorting by:"
		default: break
		}
		let items = response.items.map { $0.capitalized }
		let selectedItem = response.items.firstIndex { $0 == response.selectedItem } ?? 0
		let viewModel = Settings.SegmentedControl.ViewModel(title: title,
															typeItems: response.typeItems,
															items: items,
															selectedItem: selectedItem)
		viewController?.displaySegmentedControlItems(viewModel)
	}

	func presentSwitchState(_ response: Settings.Switch.Response) {
		var title = ""
		switch response.typeItems {
		case .forceRemovePin: title = "Ask when removing an pin:"
		default: break
		}
		let viewModel = Settings.Switch.ViewModel(title: title,
												  typeItems: response.typeItems,
												  isOn: response.isOn)
		viewController?.displaySwitchState(viewModel)
	}

	func presentRangeSliderValues(_ response: Settings.RangeSlider.Response) {
		var title = ""
		switch response.typeItems {
		case .minRangeOfRadius: title = "Set range for radius:"
		default: break
		}
		let viewModel = Settings.RangeSlider.ViewModel(title: title,
													   typeItems: response.typeItems,
													   range: response.range,
													   rangeValues: response.rangeValues,
													   userValues: response.userValues)
		viewController?.displayRangeSliderValues(viewModel)
	}

	func presentChangeValueSegmentedControl(_ response: Settings.ChangeValueSegmentedControl.Response) {
		DispatchQueue.main.async { [weak self] in
			let viewModel = Settings.ChangeValueSegmentedControl.ViewModel(isChanged: response.isChanged)
			self?.viewController?.displayChangeValueSegmentedControl(viewModel)
		}
	}

	func presentChangeValueSwitch(_ response: Settings.ChangeValueSwitch.Response) {
		DispatchQueue.main.async { [weak self] in
			let viewModel = Settings.ChangeValueSwitch.ViewModel(isChanged: response.isChanged)
			self?.viewController?.displayChangeValueSwitch(viewModel)
		}
	}

	func presentChangeValueSlider(_ response: Settings.ChangeValueRangeSlider.Response) {
		DispatchQueue.main.async { [weak self] in
			let viewModel = Settings.ChangeValueRangeSlider.ViewModel(isChanged: response.isChanged)
			self?.viewController?.displayChangeValueSlider(viewModel)
		}
	}
}
