//
//  SwitchTableViewCell.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class SwitchTableViewCell: UITableViewCell
{

	private let label = UILabel()

	let `switch` = UISwitch()

	init(title: String, isOn: Bool) {
		super.init(style: .default, reuseIdentifier: nil)
		label.text = title
		`switch`.isOn = isOn
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup() {
		contentView.addSubview(label)
		contentView.addSubview(`switch`)

		setConstraints()
	}

	private func setConstraints() {
		label.translatesAutoresizingMaskIntoConstraints = false
		`switch`.translatesAutoresizingMaskIntoConstraints = false

		// Set constraint for label
		label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
									   constant: 8).isActive = true
		label.topAnchor.constraint(equalTo: contentView.topAnchor,
								   constant: 8).isActive = true
		label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
									  constant: -8).isActive = true

		// Set constraint for segmentedControl
		`switch`.leadingAnchor.constraint(equalTo: label.trailingAnchor,
										  constant: 8).isActive = true
		`switch`.topAnchor.constraint(equalTo: contentView.topAnchor,
									  constant: 8).isActive = true
		`switch`.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
										   constant: -8).isActive = true
		`switch`.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
										 constant: -8).isActive = true
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
