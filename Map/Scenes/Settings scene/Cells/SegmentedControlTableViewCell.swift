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
		contentView.addSubview(label)
		contentView.addSubview(segmentedControl)

		setConstraints()
	}

	private func setConstraints() {
		label.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false

		// Set constraint for label
		label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
									   constant: 8).isActive = true
		label.topAnchor.constraint(equalTo: contentView.topAnchor,
								   constant: 8).isActive = true
		label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
									  constant: -8).isActive = true

		// Set constraint for segmentedControl
		segmentedControl.leadingAnchor.constraint(equalTo: label.trailingAnchor,
												  constant: 8).isActive = true
		segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor,
											  constant: 8).isActive = true
		segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
												   constant: -8).isActive = true
		segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
												 constant: -8).isActive = true
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
