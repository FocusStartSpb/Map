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
	private lazy var stack = UIStackView(arrangedSubviews: [label, `switch`])
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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateBackgroundColor()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...Private methods
	private func setup() {
		contentView.addSubview(stack)
		setConstraints()
		updateBackgroundColor()
	}

	private func setConstraints() {
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
									   constant: 16).isActive = true
		stack.topAnchor.constraint(equalTo: contentView.topAnchor,
								   constant: 8).isActive = true
		stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
									  constant: -8).isActive = true
		stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
										constant: -16).isActive = true
		stack.alignment = .center
		stack.distribution = .fillProportionally
		stack.tintColor = .red
	}

	private func updateBackgroundColor() {
		if userInterfaceStyleIsDark {
			backgroundColor = Constants.Colors.containerViewBackgroundColorInDarkMode
		}
		else {
			backgroundColor = Constants.Colors.containerViewBackgroundColorInLightMode
		}
	}
}

// MARK: - Actions
@objc private extension SwitchTableViewCell
{
	func actionToggleSwitch(_ sender: UISwitch) {
		actionToggle(sender.isOn)
	}
}
