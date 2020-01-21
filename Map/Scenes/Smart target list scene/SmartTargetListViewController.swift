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
	func displayDeleteSmartTargets(_ viewModel: SmartTargetList.DeleteSmartTargets.ViewModel)
	func displayUpdateSmartTargets(_ viewModel: SmartTargetList.UpdateSmartTargets.ViewModel)
	func updateEditedSmartTarget(_ viewModel: SmartTargetList.UpdateSmartTarget.ViewModel)
	func showEmptyView(_ viewModel: SmartTargetList.ShowEmptyView.ViewModel)
}

// MARK: - Class
final class SmartTargetListViewController: UIViewController
{
	// MARK: ...Private properties
	private var interactor: SmartTargetListBusinessLogic
	var router: SmartTargetListRoutingLogic & SmartTargetListDataPassing
	private let targetsTableView = UITableView()
	private let emptyView = EmptyView()
	private var userInterfaceIsDark: Bool {
		if #available(iOS 12.0, *) {
			return self.traitCollection.userInterfaceStyle == .dark ? true : false
		}
		return false
	}

	private enum StaticConstants
	{
		static let navigationItemTitle = "Список локаций"
		static let reuseIdentifier = "Cell"
		static let selectedCellBackgroundColorInDarkMode = #colorLiteral(red: 0.3045190282, green: 0.3114352223, blue: 0.3184640712, alpha: 1)
		static let selectedCellBackgroundColorInLightMode = #colorLiteral(red: 0.7502671557, green: 0.7502671557, blue: 0.7502671557, alpha: 1)
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
		router.dataStore?.didUpdateAllSmartTargets = true
		updateNavigationBar()
		checkUserInterfaceStyle()
		setupTargetsTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tabBarController?.delegate = self
		router.dataStore?.removedIndexSet = nil
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		interactor.updateSmartTarget(.init())
		interactor.updateSmartTargets(.init())
	}

	// MARK: ...Private methods
	private func updateNavigationBar() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.title = StaticConstants.navigationItemTitle
	}

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
									   forCellReuseIdentifier: StaticConstants.reuseIdentifier)
		self.targetsTableView.allowsSelectionDuringEditing = true
	}

	private func checkUserInterfaceStyle() {
		if self.userInterfaceIsDark == true {
			self.targetsTableView.backgroundColor = #colorLiteral(red: 0.2204069229, green: 0.2313892178, blue: 0.253805164, alpha: 1)
			self.view.backgroundColor = #colorLiteral(red: 0.2204069229, green: 0.2313892178, blue: 0.253805164, alpha: 1)
			self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
		}
		else {
			self.view.backgroundColor = .white
			self.targetsTableView.backgroundColor = #colorLiteral(red: 0.9871620841, green: 0.9871620841, blue: 0.9871620841, alpha: 1)
			self.navigationController?.navigationBar.barTintColor = .white
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		checkUserInterfaceStyle()
	}
}

// MARK: - Smart target list display logic
extension SmartTargetListViewController: SmartTargetListDisplayLogic
{
	func displayDeleteSmartTargets(_ viewModel: SmartTargetList.DeleteSmartTargets.ViewModel) {
		if viewModel.didDelete, let indexSet = viewModel.removedIndexSet {
			targetsTableView.deleteSections(indexSet, with: .fade)
		}
		else if viewModel.showAlertForceRemovePin {
			Alerts.showDeletePinAlert(on: self) { }
		}
	}

	func displayUpdateSmartTargets(_ viewModel: SmartTargetList.UpdateSmartTargets.ViewModel) {
		guard viewModel.needUpdate else { return }
		targetsTableView.beginUpdates()
		targetsTableView.deleteSections(viewModel.removedIndexSet, with: .fade)
		targetsTableView.reloadSections(viewModel.updatedIndexSet, with: .fade)
		targetsTableView.insertSections(viewModel.addedIndexSet, with: .fade)
		targetsTableView.endUpdates()
	}

	func updateEditedSmartTarget(_ viewModel: SmartTargetList.UpdateSmartTarget.ViewModel) {
		guard viewModel.needUpdate else { return }
		targetsTableView.reloadSections(viewModel.updatedIndexSet, with: .fade)
	}

	func showEmptyView(_ viewModel: SmartTargetList.ShowEmptyView.ViewModel) {
		viewModel.showEmptyView == true ? self.emptyView.pinToSuperview(superview: self.view) : self.emptyView.leave()
	}
}
// MARK: - TableViewDataSource
extension SmartTargetListViewController: UITableViewDataSource
{
	func numberOfSections(in tableView: UITableView) -> Int {
		interactor.showEmptyView(.init())
		return router.dataStore?.smartTargetsCount ?? 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: StaticConstants.reuseIdentifier)
			as? SmartTargetTableViewCell
			else {
			return UITableViewCell()
		}
		cell.fillLabels(with: router.dataStore?.smartTargetCollection.smartTargets[indexPath.section])
		return cell
	}
}
// MARK: - TableViewDelegate
extension SmartTargetListViewController: UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 15
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		UIView()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? SmartTargetTableViewCell else { return }
		let backgroundColorDefault = cell.containerView.backgroundColor
		var selectedBackgroundColor: UIColor {
			if userInterfaceIsDark {
				return StaticConstants.selectedCellBackgroundColorInDarkMode
			}
			else {
				return StaticConstants.selectedCellBackgroundColorInLightMode
			}
		}
		UIView.animate(withDuration: 0.2, animations: { cell.containerView.backgroundColor = selectedBackgroundColor })
		self.router.routeToDetail(indexPathAtRow: indexPath.section)
		tableView.deselectRow(at: indexPath, animated: false)
		UIView.animate(withDuration: 0.2, delay: 0.5,
						   animations: { cell.containerView.backgroundColor = backgroundColorDefault })
	}

	func tableView(_ tableView: UITableView,
				   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
			self?.actionRemove(indexSet: [indexPath.section], completionHandler: completion)
		}
		return UISwipeActionsConfiguration(actions: [action])
	}
}

extension SmartTargetListViewController: UITabBarControllerDelegate
{
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		tabBarController.delegate = nil
		guard let mapViewController = tabBarController
			.viewControllers?
			.first(where: { $0 is MapViewController }) as? MapViewController else {
				return false
		}
		mapViewController.router.dataStore?.didUpdateAllAnnotations = false
		return true
	}
}

private extension SmartTargetListViewController
{
	func actionRemove(indexSet: IndexSet, completionHandler: @escaping (Bool) -> Void) {
		let request =
			SmartTargetList.DeleteSmartTargets.Request(smartTargetsIndexSet: indexSet,
													   removedIndexSet: indexSet,
													   completionHandler: completionHandler)
		interactor.deleteSmartTargets(request)
	}
}
