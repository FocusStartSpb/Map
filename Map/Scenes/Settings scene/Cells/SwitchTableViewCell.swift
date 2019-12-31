//
//  SwitchTableViewCell.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class SwitchTableViewCell: UITableViewCell
{

	// MARK: ...Private properties
	private let label = UILabel()
	private lazy var `switch`: UISwitch = {
		let `switch` = UISwitch()
		`switch`.addTarget(self, action: #selector(actionToggleSwitch(_:)), for: .valueChanged)
		return `switch`
	}()
	private let actionToggle: (Bool) -> Void

	// MARK: ...Internal properties
	var isOn: Bool {
		get { `switch`.isOn }
		set { `switch`.isOn = newValue }
	}
	var title: String? {
		get { label.text }
		set { label.text = newValue }
	}

	// MARK: ...Initialization
	init(actionToggle: @escaping (Bool) -> Void) {
		self.actionToggle = actionToggle
		super.init(style: .default, reuseIdentifier: nil)
		selectionStyle = .none
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...Private methods
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

		// Set constraint for switch
		`switch`.leadingAnchor.constraint(equalTo: label.trailingAnchor,
										  constant: 8).isActive = true
		`switch`.topAnchor.constraint(equalTo: contentView.topAnchor,
									  constant: 8).isActive = true
		`switch`.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
										   constant: -8).isActive = true
		`switch`.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
										 constant: -8).isActive = true
	}
}

// MARK: - Actions
@objc private extension SwitchTableViewCell
{
	func actionToggleSwitch(_ sender: UISwitch) {
		actionToggle(sender.isOn)
	}
}
