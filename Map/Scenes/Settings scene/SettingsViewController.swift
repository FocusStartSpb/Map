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
}

// MARK: - Class
final class SettingsViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: SettingsBusinessLogic?

	// MARK: ...Cells
	private lazy var measuringSystemCell =
		SegmentedControlTableViewCell(actionChangeValue: actionChangeMeasuringSystem)
	private lazy var sortingCell =
		SegmentedControlTableViewCell(actionChangeValue: actionChangeSorting)
	private lazy var forceRemovePinCell =
		SwitchTableViewCell(actionToggle: actionToggleForceRemovePin)
	private lazy var rangeRadiusCell =
		RangeSliderTableViewCell(actionChangeValue: actionChangeRangeRadius)

	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.dataSource = self
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
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
		title = "Settings"

		view.addSubview(tableView)

		interactor?.getSegmentedControlItems(.init(typeItems: .measuringSystem))
		interactor?.getSegmentedControlItems(.init(typeItems: .sorting))
		interactor?.getSwitchState(.init(typeItems: .forceRemovePin))
		interactor?.getRangeSliderValues(.init(typeItems: .minRangeOfRadius))

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
		case .measuringSystem:
			measuringSystemCell.title = viewModel.title
			measuringSystemCell.setItems(viewModel.items)
			measuringSystemCell.selectedSegmentIndex = viewModel.selectedItem
		case .sorting:
			sortingCell.title = viewModel.title
			sortingCell.setItems(viewModel.items)
			sortingCell.selectedSegmentIndex = viewModel.selectedItem
		default: break
		}
	}

	func displaySwitchState(_ viewModel: Settings.Switch.ViewModel) {
		switch viewModel.typeItems {
		case .forceRemovePin:
			forceRemovePinCell.title = viewModel.title
			forceRemovePinCell.isOn = viewModel.isOn
		default: break
		}
	}

	func displayRangeSliderValues(_ viewModel: Settings.RangeSlider.ViewModel) {
		switch viewModel.typeItems {
		case .minRangeOfRadius:
			rangeRadiusCell.title = viewModel.title
			rangeRadiusCell.minRange = viewModel.range
			rangeRadiusCell.rangeValues = viewModel.rangeValues
			rangeRadiusCell.values = viewModel.userValues
		default: break
		}
	}

	func displayChangeValueSegmentedControl(_ viewModel: Settings.ChangeValueSegmentedControl.ViewModel) { }

	func displayChangeValueSwitch(_ viewModel: Settings.ChangeValueSwitch.ViewModel) { }

	func displayChangeValueSlider(_ viewModel: Settings.ChangeValueRangeSlider.ViewModel) { }
}

// MARK: - Table view data source
extension SettingsViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		4
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0: return measuringSystemCell
		case 1: return sortingCell
		case 2: return forceRemovePinCell
		case 3: return rangeRadiusCell
		default: return UITableViewCell()
		}
	}
}

// MARK: - Actions
private extension SettingsViewController
{
	func actionChangeMeasuringSystem(_ value: String) {
		let request = Settings.ChangeValueSegmentedControl.Request(value: value, typeItems: .measuringSystem)
		interactor?.changeValueSegmentedControl(request)
	}

	func actionChangeSorting(_ value: String) {
		let request = Settings.ChangeValueSegmentedControl.Request(value: value, typeItems: .sorting)
		interactor?.changeValueSegmentedControl(request)
	}

	func actionToggleForceRemovePin(_ value: Bool) {
		let request = Settings.ChangeValueSwitch.Request(value: value, typeItems: .forceRemovePin)
		interactor?.changeValueSwitch(request)
	}

	func actionChangeRangeRadius(_ value: (lower: Double, upper: Double)) {
		let request = Settings.ChangeValueRangeSlider.Request(values: value, typeItems: .lowerValueOfRadius)
		interactor?.changeValueSlider(request)
	}
}
