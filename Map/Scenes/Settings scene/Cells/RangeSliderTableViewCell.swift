//
//  RangeSliderTableViewCell.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class RangeSliderTableViewCell: UITableViewCell
{
	// MARK: . ..Private properties
	private let label = UILabel()
	private lazy var rangeSlider: RangeSlider = {
		let rangeSlider = RangeSlider()
		rangeSlider.addTarget(self, action: #selector(actionChangeValue(_:)), for: .valueChanged)
		return rangeSlider
	}()
	private let actionChangeValue: (((lower: Double, upper: Double)) -> Void)

	// MARK: ...Internal properties
	var minRange: Double {
		get { rangeSlider.minRange }
		set { rangeSlider.minRange = newValue }
	}
	var rangeValues: (min: Double, max: Double) {
		get { (rangeSlider.minimumValue, rangeSlider.maximumValue) }
		set {
			rangeSlider.minimumValue = newValue.min
			rangeSlider.maximumValue = newValue.max
		}
	}
	var values: (lower: Double, upper: Double) {
		get { (rangeSlider.lowerValue, rangeSlider.upperValue) }
		set {
			rangeSlider.lowerValue = newValue.lower
			rangeSlider.upperValue = newValue.upper
		}
	}
	var title: String? {
		get { label.text }
		set { label.text = newValue }
	}

	// MARK: ...Initialization
	init(actionChangeValue: @escaping ((lower: Double, upper: Double)) -> Void) {
		self.actionChangeValue = actionChangeValue
		super.init(style: .default, reuseIdentifier: nil)
		selectionStyle = .none
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		setFrames()
	}

	// MARK: ...Private methods
	private func setup() {
		contentView.addSubview(label)
		contentView.addSubview(rangeSlider)
	}

	private func setFrames() {
		label.sizeToFit()
		label.frame = CGRect(x: 8,
							 y: (contentView.frame.height - label.frame.height) / 2,
							 width: label.frame.width,
							 height: label.frame.height)
		rangeSlider.frame = CGRect(x: label.frame.maxX + 8,
								   y: (contentView.frame.height - 30) / 2,
								   width: contentView.frame.width - label.frame.maxX - 2 * 8,
								   height: 30)
	}
}

// MARK: - Actions
@objc private extension RangeSliderTableViewCell
{
	func actionChangeValue(_ sender: RangeSlider) {
		actionChangeValue((sender.lowerValue, sender.upperValue))
	}
}
