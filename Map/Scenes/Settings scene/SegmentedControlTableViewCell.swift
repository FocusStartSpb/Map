//
//  SegmentedControlTableViewCell.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class SegmentedControlTableViewCell: UITableViewCell
{

	private let label = UILabel()

	let segmentedControl = UISegmentedControl()

	init(title: String, items: [String]) {
		super.init(style: .default, reuseIdentifier: nil)
		label.text = title
		items.reversed().forEach {
			segmentedControl.insertSegment(withTitle: $0, at: 0, animated: false)
		}

		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

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

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
