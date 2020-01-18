//
//  SettingsInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import Foundation

// MARK: - SettingsBusinessLogic protocol
protocol SettingsBusinessLogic
{
	func getSegmentedControlItems(_ request: Settings.SegmentedControl.Request)
	func getSwitchState(_ request: Settings.Switch.Request)
	func getRangeSliderValues(_ request: Settings.RangeSlider.Request)
	func changeValueSegmentedControl(_ request: Settings.ChangeValueSegmentedControl.Request)
	func changeValueSwitch(_ request: Settings.ChangeValueSwitch.Request)
	func changeValueSlider(_ request: Settings.ChangeValueRangeSlider.Request)
	func getMeasurementSystem(_ request: Settings.GetMeasurementSystem.Request)
}

// MARK: - Class
final class SettingsInteractor
{
	// MARK: ...Private properties
	private let presenter: SettingsPresentationLogic
	private let settingsWorker: SettingsSceneWorker

	private var pendingRequesrWorkItem: DispatchWorkItem?
	private let dispatchQueueSaveSettings =
		DispatchQueue(label: "com.map.saveSettings",
					  qos: .utility,
					  attributes: .concurrent)

	// MARK: ...Initialization
	init(presenter: SettingsPresentationLogic, settingsWorker: SettingsSceneWorker) {
		self.presenter = presenter
		self.settingsWorker = settingsWorker
	}

	// MARK: ...Private methods
	private func perform(after: TimeInterval, _ block: @escaping () -> Void) {
		pendingRequesrWorkItem?.cancel()

		let requestWorkItem = DispatchWorkItem(block: block)

		pendingRequesrWorkItem = requestWorkItem

		dispatchQueueSaveSettings.asyncAfter(deadline: .now() + after,
											 execute: requestWorkItem)
	}
}

// MARK: - Settings business logic Protocol
extension SettingsInteractor: SettingsBusinessLogic
{
	func getSegmentedControlItems(_ request: Settings.SegmentedControl.Request) {
		var response: Settings.SegmentedControl.Response?
		switch request.typeItems {
		case .measurementSystem:
			let items = settingsWorker.getMeasurementSystemItems()
			let selectedItem = settingsWorker.measurementSystem?.rawValue ?? ""
			response = .init(typeItems: request.typeItems, items: items, selectedItem: selectedItem)
		case .sorting:
			let items = settingsWorker.getSortingItems()
			let selectedItem = settingsWorker.sorting?.rawValue ?? ""
			response = .init(typeItems: request.typeItems, items: items, selectedItem: selectedItem)
		default: break
		}
		guard let responseResult = response else { return }
		presenter.presentSegmentedControlItems(responseResult)
	}

	func getSwitchState(_ request: Settings.Switch.Request) {
		var response: Settings.Switch.Response?
		switch request.typeItems {
		case .forceRemovePin:
			let isOn = settingsWorker.forceRemovePin ?? false
			response = .init(typeItems: request.typeItems, isOn: isOn)
		default: break
		}
		guard let responseResult = response else { return }
		presenter.presentSwitchState(responseResult)
	}

	func getRangeSliderValues(_ request: Settings.RangeSlider.Request) {
		var response: Settings.RangeSlider.Response?
		switch request.typeItems {
		case .minRangeOfRadius, .minValueOfRadius, .maxValueOfRadius, .lowerValueOfRadius, .upperValueOfRadius:
			let range = settingsWorker.minRangeOfRadius
			let minValue = settingsWorker.minValueOfRadius
			let maxValue = settingsWorker.maxValueOfRadius
			let lowerValue = settingsWorker.lowerValueOfRadius ?? 0
			let upperValue = settingsWorker.upperValueOfRadius ?? 0
			response = .init(typeItems: request.typeItems,
							 range: range,
							 rangeValues: (minValue, maxValue),
							 userValues: (lowerValue, upperValue))
		default: break
		}
		guard let responseResult = response else { return }
		presenter.presentRangeSliderValues(responseResult)
	}

	func changeValueSegmentedControl(_ request: Settings.ChangeValueSegmentedControl.Request) {
		dispatchQueueSaveSettings.async { [weak self] in
			switch request.typeItems {
			case .measurementSystem:
				let value = UserPreferences.MeasurementSystem(rawValue: request.value)
				self?.settingsWorker.measurementSystem = value
			case .sorting:
				let value = UserPreferences.Sorting(rawValue: request.value.lowercased())
				self?.settingsWorker.sorting = value
			default: break
			}
			let response = Settings.ChangeValueSegmentedControl.Response(isChanged: true, typeItems: request.typeItems)
			self?.presenter.presentChangeValueSegmentedControl(response)
		}
	}

	func changeValueSwitch(_ request: Settings.ChangeValueSwitch.Request) {
		dispatchQueueSaveSettings.async { [weak self] in
			switch request.typeItems {
			case .forceRemovePin:
				self?.settingsWorker.forceRemovePin = request.value
			default: break
			}
			let response = Settings.ChangeValueSwitch.Response(isChanged: true, typeItems: request.typeItems)
			self?.presenter.presentChangeValueSwitch(response)
		}
	}

	func changeValueSlider(_ request: Settings.ChangeValueRangeSlider.Request) {
		perform(after: 0.1) { [weak self] in
			switch request.typeItems {
			case .lowerValueOfRadius, .upperValueOfRadius:
				self?.settingsWorker.lowerValueOfRadius = request.values.lower
				self?.settingsWorker.upperValueOfRadius = request.values.upper
			default: break
			}
			let response = Settings.ChangeValueRangeSlider.Response(isChanged: true, typeItems: request.typeItems)
			self?.presenter.presentChangeValueSlider(response)
		}
	}

	func getMeasurementSystem(_ request: Settings.GetMeasurementSystem.Request) {
		let measurementSystem = settingsWorker.measurementSystem ?? .metric
		let response = Settings.GetMeasurementSystem.Response(measurementSystem: measurementSystem)
		presenter.presentGetMeasurementSystem(response)
	}
}
