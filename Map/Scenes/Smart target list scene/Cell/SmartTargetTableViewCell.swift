//
//  SmartTargetTableViewCell.swift
//  Map
//
//  Created by Антон on 23.12.2019.
//

import UIKit

final class SmartTargetTableViewCell: UITableViewCell
{
	private let titleLabel = UILabel()
	private let addressLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupTitleLabel()
		setupAddressLabel()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupTitleLabel() {
		self.contentView.addSubview(titleLabel)
		self.titleLabel.numberOfLines = 0
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
		])
	}

	private func setupAddressLabel() {
		self.contentView.addSubview(addressLabel)
		self.addressLabel.numberOfLines = 0
		self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.addressLabel.leadingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.addressLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
			self.addressLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.addressLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
		])
	}
}
