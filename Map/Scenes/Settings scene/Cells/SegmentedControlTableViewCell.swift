//
//  SegmentedControlTableViewCell.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class SegmentedControlTableViewCell: UITableViewCell
{

	// MARK: ...Private properties
	private lazy var stack = UIStackView(arrangedSubviews: [label, segmentedControl])
	private let label = UILabel()
	private lazy var segmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl()
		segmentedControl.addTarget(self, action: #selector(actionChangeValue(_:)), for: .valueChanged)
		return segmentedControl
	}()
	private let actionChangeValue: ((String) -> Void)

	// MARK: ...Internal properties
	var selectedSegmentIndex: Int {
		get { segmentedControl.selectedSegmentIndex }
		set { segmentedControl.selectedSegmentIndex = newValue }
	}
	var title: String? {
		get { label.text }
		set { label.text = newValue }
	}

	// MARK: ...Initialization
	init(actionChangeValue: @escaping (String) -> Void) {
		self.actionChangeValue = actionChangeValue
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
		contentView.addSubview(stack)
		setConstraints()
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
	}

	// MARK: ...Internal methods
	func setItems(_ items: [String]) {
		items.reversed().forEach {
			segmentedControl.insertSegment(withTitle: $0, at: 0, animated: false)
		}
	}
}

// MARK: - Actions
@objc private extension SegmentedControlTableViewCell
{
	func actionChangeValue(_ sender: UISegmentedControl) {
		actionChangeValue(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "")
	}
}
