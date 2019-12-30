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
	func displaySomething(viewModel: Settings.Something.ViewModel)
}

// MARK: - Class
final class SettingsViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: SettingsBusinessLogic?

	private let dataSource = SettingsDataSource()

	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.delegate = self
		tableView.dataSource = dataSource
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
		view.addSubview(tableView)
		setupConstraints()
	}

	private func setupConstraints() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
	}
}

// MARK: - Settings display logic
extension SettingsViewController: SettingsDisplayLogic
{
	func displaySomething(viewModel: Settings.Something.ViewModel) {
	}
}

// MARK: - Table view data source
extension SettingsViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		3
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0: return SegmentedControlTableViewCell(title: "Hello", items: ["Hello1", "Hello2", "Hello3"])
		case 1: return SegmentedControlTableViewCell(title: "HDHDHD", items: ["dadsada", "asdads"])
		case 2: return SwitchTableViewCell(title: "sdsd", isOn: true)
		default: return UITableViewCell()
		}
	}
}

// MARK: - Table view delegate
extension SettingsViewController: UITableViewDelegate
{
}

final class SettingsDataSource: NSObject, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		UITableViewCell()
	}
}
