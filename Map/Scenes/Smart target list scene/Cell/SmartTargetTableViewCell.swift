//
//  SmartTargetTableViewCell.swift
//  Map
//
//  Created by Антон on 26.12.2019.
//

import UIKit

protocol ISmartTargetTableViewCell
{
	func fillLabels(with smartTarget: SmartTarget?)
}

final class SmartTargetTableViewCell: UITableViewCell
{
	let containerView = UIView()
	private let selectedView = UIView()
	private let timeOfCreationLabel = UILabel()
	private let titleLabel = UILabel()
	private let addressLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupContainerView()
		setupTimeOfCreationLabel()
		setupTitleLabel()
		setupAddressLabel()
		selectionStyle = .none
		updateBackgroundColors()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateBackgroundColors()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	// MARK: ... Private Methods
	private func setupContainerView() {
		self.contentView.addSubview(containerView)
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
			self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
			self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
		])
		self.containerView.layer.cornerRadius = 20
		self.containerView.layer.shadowOpacity = 0.3
		self.containerView.layer.shadowOffset = CGSize(width: self.containerView.frame.width,
													   height: self.containerView.frame.height + 7)
		self.containerView.layer.borderWidth = 0.07
	}

	private func setupTimeOfCreationLabel() {
		self.containerView.addSubview(timeOfCreationLabel)
		self.timeOfCreationLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.timeOfCreationLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.timeOfCreationLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
			self.timeOfCreationLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.timeOfCreationLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 7),
		])
		self.timeOfCreationLabel.font = Constants.Fonts.ForCells.timeOfCreation
		self.timeOfCreationLabel.textAlignment = .center
	}

	private func setupTitleLabel() {
		self.containerView.addSubview(titleLabel)
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor,
													 constant: 5),
			self.titleLabel.topAnchor.constraint(equalTo: self.timeOfCreationLabel.bottomAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor,
													  constant: -5),
			self.titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 10),
		])
		self.titleLabel.numberOfLines = 0
		self.titleLabel.font = Constants.Fonts.ForCells.titleLabel
		self.titleLabel.textAlignment = .center
	}

	private func setupAddressLabel() {
		self.containerView.addSubview(addressLabel)
		self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
		let topAnchor =
			self.addressLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,
												   constant: 5)
		topAnchor.priority = .defaultHigh
		topAnchor.isActive = true
		NSLayoutConstraint.activate([
			self.addressLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor,
													   constant: 5),
			self.addressLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor,
														constant: -5),
			self.addressLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -5),
		])
		self.addressLabel.numberOfLines = 0
		self.addressLabel.font = Constants.Fonts.ForCells.addressLabel
		self.addressLabel.textAlignment = .center
	}

	private func updateBackgroundColors() {
		if self.userInterfaceStyleIsDark == true {
			self.containerView.backgroundColor = Constants.Colors.containerViewBackgroundColorInDarkMode
			self.contentView.backgroundColor = Constants.Colors.contentViewBackgroundColorInDarkMode
		}
		else {
			self.containerView.backgroundColor = Constants.Colors.containerViewBackgroundColorInLightMode
			self.contentView.backgroundColor = Constants.Colors.contentViewBackgroundColorInLightMode
		}
	}
}
// MARK: - ISmartTargetTableViewCell
extension SmartTargetTableViewCell: ISmartTargetTableViewCell
{
	func fillLabels(with smartTarget: SmartTarget?) {
		self.titleLabel.text = smartTarget?.title
		self.addressLabel.text = smartTarget?.address
		self.timeOfCreationLabel.text = Formatter.medium.string(from: smartTarget?.dateOfCreated ?? Date())
	}
}
