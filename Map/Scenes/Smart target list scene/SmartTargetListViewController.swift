//
//  SmartTargetListViewController.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import UIKit

// MARK: - SmartTargetListDisplayLogic protocol
protocol SmartTargetListDisplayLogic: AnyObject
{
	func displayLoadSmartTargets(_ viewModel: SmartTargetList.LoadSmartTargets.ViewModel)
	func displaySaveSmartTargets(_ viewModel: SmartTargetList.SaveSmartTargets.ViewModel)
}

// MARK: - Class
final class SmartTargetListViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: SmartTargetListBusinessLogic & SmartTargetListDataStore
	private var router: (SmartTargetListRoutingLogic & SmartTargetListDataPassing)
	private let targetsTableView = UITableView()
	private let targetsCell = SmartTargetTableViewCell()

	private enum CellBackgroundColor
	{
		static let selectedCellBackgroundColor = #colorLiteral(red: 0.5475797056, green: 0.5739227794, blue: 0.6377512708, alpha: 1)
		static var notSelectedCellBackgroundColor: UIColor {
			if #available(iOS 13.0, *) {
				return .systemBackground
			}
			else {
				return .white
			}
		}
	}

	// MARK: ...Initialization
	init(interactor: SmartTargetListBusinessLogic & SmartTargetListDataStore,
		 router: (SmartTargetListRoutingLogic & SmartTargetListDataPassing)) {
		self.interactor = interactor
		self.router = router
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...View lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTargetsTableView()
		interactor.loadSmartTargets(SmartTargetList.LoadSmartTargets.Request())
	}

	// MARK: ...Private methods
	private func setupTargetsTableView() {
		self.view.addSubview(targetsTableView)
		self.targetsTableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.targetsTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.targetsTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.targetsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.targetsTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
		])
		self.targetsTableView.dataSource = self
		self.targetsTableView.delegate = self
		self.targetsTableView.separatorStyle = .none
		self.targetsTableView.register(SmartTargetTableViewCell.self,
									   forCellReuseIdentifier: "Cell")
	}
}

// MARK: - Smart target list display logic
extension SmartTargetListViewController: SmartTargetListDisplayLogic
{
	func displayLoadSmartTargets(_ viewModel: SmartTargetList.LoadSmartTargets.ViewModel) {
	}

	func displaySaveSmartTargets(_ viewModel: SmartTargetList.SaveSmartTargets.ViewModel) {
	}
}
// MARK: - TableViewDataSource
extension SmartTargetListViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return interactor.smartTargetsCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SmartTargetTableViewCell else {
			return UITableViewCell()
		}
		cell.fillLabels(smartTarget: interactor.getSmartTarget(by: indexPath.row))
		return cell
	}
}
// MARK: - TableViewDelegate
extension SmartTargetListViewController: UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? SmartTargetTableViewCell else { return }
		UIView.animate(withDuration: 0.2,
					   animations: { cell.containerView.backgroundColor = CellBackgroundColor.selectedCellBackgroundColor })
		tableView.deselectRow(at: indexPath, animated: true)
		UIView.animate(withDuration: 0.2,
					   delay: 0.2,
					   animations: { cell.containerView.backgroundColor = CellBackgroundColor.notSelectedCellBackgroundColor })
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let degree: Double = 90
		let rotationAngle = CGFloat(degree * .pi / 180)
		let rotationTransform = CATransform3DMakeRotation(rotationAngle, 1, 0, 0)
		cell.layer.transform = rotationTransform
		UIView.animate(withDuration: 0.7,
					   delay: 0.02 * Double(indexPath.row),
					   options: .curveEaseOut,
					   animations: { cell.layer.transform = CATransform3DIdentity })
	}
}
