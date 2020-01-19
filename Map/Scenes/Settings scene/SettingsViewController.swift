//
//  SettingsViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

// MARK: - SettingsDisplayLogic Protocol
protocol SettingsDisplayLogic: AnyObject
{
	func displaySegmentedControlItems(_ viewModel: Settings.SegmentedControl.ViewModel)
	func displaySwitchState(_ viewModel: Settings.Switch.ViewModel)
	func displayRangeSliderValues(_ viewModel: Settings.RangeSlider.ViewModel)
	func displayChangeValueSegmentedControl(_ viewModel: Settings.ChangeValueSegmentedControl.ViewModel)
	func displayChangeValueSwitch(_ viewModel: Settings.ChangeValueSwitch.ViewModel)
	func displayChangeValueSlider(_ viewModel: Settings.ChangeValueRangeSlider.ViewModel)
	func displayGetMeasurementSystem(_ viewModel: Settings.GetMeasurementSystem.ViewModel)
}

// MARK: - Class
final class SettingsViewController: UIViewController
{
	enum CellType: Int
	{
		case measurementSystem, forceRemovePin, rangeRadius, none
	}

	// MARK: ...Private properties
	private let interactor: SettingsBusinessLogic

	// MARK: ...Cells
	private var cells: [UITableViewCell] {
		[measurementSystemCell, forceRemovePinCell, rangeRadiusCell]
	}

	private var headerTitles: [CellType: String] = [
		.measurementSystem: "",
		.forceRemovePin: "",
		.rangeRadius: "",
		.none: "",
	]

	private var footerTitles: [CellType: String] = [
		.measurementSystem: "",
		.forceRemovePin: "",
		.rangeRadius: "",
		.none: "",
	]

	private lazy var measurementSystemCell =
		SegmentedControlTableViewCell(actionChangeValue: actionChangeMeasurementSystem)
	private lazy var forceRemovePinCell =
		SwitchTableViewCell(actionToggle: actionToggleForceRemovePin)
	private lazy var rangeRadiusCell =
		RangeSliderTableViewCell(actionChangeValue: actionChangeRangeRadius)

	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.dataSource = self
		tableView.isScrollEnabled = false
		return tableView
	}()

	// MARK: ...Initialization
	init(interactor: SettingsBusinessLogic) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}

	// MARK: ...Setup
	private func setup() {
		title = tabBarItem.title

		view.addSubview(tableView)

		interactor.getSegmentedControlItems(.init(typeItems: .measurementSystem))
		interactor.getSegmentedControlItems(.init(typeItems: .sorting))
		interactor.getSwitchState(.init(typeItems: .forceRemovePin))
		interactor.getRangeSliderValues(.init(typeItems: .minRangeOfRadius))
		interactor.getMeasurementSystem(.init())

		setupConstraints()
	}

	private func setupConstraints() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
}

// MARK: - Settings display logic
extension SettingsViewController: SettingsDisplayLogic
{
	func displaySegmentedControlItems(_ viewModel: Settings.SegmentedControl.ViewModel) {
		switch viewModel.typeItems {
		case .measurementSystem:
			headerTitles[.measurementSystem] = viewModel.headerTitle
			footerTitles[.measurementSystem] = viewModel.footerTitle
			measurementSystemCell.title = viewModel.title
			measurementSystemCell.setItems(viewModel.items)
			measurementSystemCell.selectedSegmentIndex = viewModel.selectedItem
		default: break
		}
	}

	func displaySwitchState(_ viewModel: Settings.Switch.ViewModel) {
		switch viewModel.typeItems {
		case .forceRemovePin:
			headerTitles[.forceRemovePin] = viewModel.headerTitle
			footerTitles[.forceRemovePin] = viewModel.footerTitle
			forceRemovePinCell.title = viewModel.title
			forceRemovePinCell.isOn = viewModel.isOn
		default: break
		}
	}

	func displayRangeSliderValues(_ viewModel: Settings.RangeSlider.ViewModel) {
		switch viewModel.typeItems {
		case .minRangeOfRadius:
			headerTitles[.rangeRadius] = viewModel.headerTitle
			footerTitles[.rangeRadius] = viewModel.footerTitle
			rangeRadiusCell.title = viewModel.title
			rangeRadiusCell.minRange = viewModel.range
			rangeRadiusCell.rangeValues = viewModel.rangeValues
			rangeRadiusCell.values = viewModel.userValues
		default: break
		}
	}

	func displayChangeValueSegmentedControl(_ viewModel: Settings.ChangeValueSegmentedControl.ViewModel) {
		switch viewModel.typeItems {
		case .measurementSystem: interactor.getMeasurementSystem(.init())
		default: break
		}
	}

	func displayChangeValueSwitch(_ viewModel: Settings.ChangeValueSwitch.ViewModel) { }

	func displayChangeValueSlider(_ viewModel: Settings.ChangeValueRangeSlider.ViewModel) { }

	func displayGetMeasurementSystem(_ viewModel: Settings.GetMeasurementSystem.ViewModel) {
		rangeRadiusCell.sliderFactor = viewModel.measurementFactor
		rangeRadiusCell.sliderValueSymbol = viewModel.measurementSymbol
	}
}

// MARK: - Table view data source
extension SettingsViewController: UITableViewDataSource
{
	func numberOfSections(in tableView: UITableView) -> Int { 3 }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cells[indexPath.section]
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		headerTitles[CellType(rawValue: section) ?? .none]
	}

	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		footerTitles[CellType(rawValue: section) ?? .none]
	}
}

// MARK: - Actions
private extension SettingsViewController
{
	func actionChangeMeasurementSystem(_ value: String) {
		let request = Settings.ChangeValueSegmentedControl.Request(value: value, typeItems: .measurementSystem)
		interactor.changeValueSegmentedControl(request)
	}

	func actionToggleForceRemovePin(_ value: Bool) {
		let request = Settings.ChangeValueSwitch.Request(value: value, typeItems: .forceRemovePin)
		interactor.changeValueSwitch(request)
	}

	func actionChangeRangeRadius(_ value: (lower: Double, upper: Double)) {
		let request = Settings.ChangeValueRangeSlider.Request(values: value, typeItems: .lowerValueOfRadius)
		interactor.changeValueSlider(request)
	}
}
