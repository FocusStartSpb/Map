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
	private let lowerValuelabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12)
		label.textAlignment = .right
		return label
	}()
	private let upperValuelabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12)
		label.textAlignment = .left
		return label
	}()
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
			updateSliderLabels()
		}
	}
	var title: String? {
		get { label.text }
		set { label.text = newValue }
	}

	var sliderFactor: Double = 1 {
		didSet { updateSliderLabels() }
	}

	var sliderValueSymbol: String = "" {
		didSet { updateSliderLabels() }
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
		contentView.addSubview(lowerValuelabel)
		contentView.addSubview(upperValuelabel)
	}

	private func setFrames() {
		label.sizeToFit()
		lowerValuelabel.sizeToFit()
		upperValuelabel.sizeToFit()
		let rightOffsetOfLabel: CGFloat = (label.text?.isEmpty == false) ? 8 : 0
		label.frame = CGRect(x: 16,
							 y: (contentView.frame.height - label.frame.height) / 2,
							 width: label.frame.width,
							 height: label.frame.height)
		lowerValuelabel.frame = CGRect(x: label.frame.maxX + rightOffsetOfLabel,
									   y: (contentView.frame.height - lowerValuelabel.frame.height) / 2,
									   width: 60,
									   height: lowerValuelabel.frame.height)
		rangeSlider.frame = CGRect(x: lowerValuelabel.frame.maxX + 8,
								   y: (contentView.frame.height - 30) / 2,
								   width: contentView.frame.width - lowerValuelabel.frame.maxX - 16 - 2 * 8 - 60,
								   height: 30)
		upperValuelabel.frame = CGRect(x: rangeSlider.frame.maxX + 8,
									   y: (contentView.frame.height - upperValuelabel.frame.height) / 2,
									   width: 60,
									   height: upperValuelabel.frame.height)
	}

	private func updateSliderLabels() {
		lowerValuelabel.text =
			"\(Int(values.lower * sliderFactor))" +
			((sliderValueSymbol.isEmpty == false) ? " \(sliderValueSymbol)" : "")
		upperValuelabel.text =
			"\(Int(values.upper * sliderFactor))" +
			((sliderValueSymbol.isEmpty == false) ? " \(sliderValueSymbol)" : "")
	}
}

// MARK: - Actions
@objc private extension RangeSliderTableViewCell
{
	func actionChangeValue(_ sender: RangeSlider) {
		values = (sender.lowerValue, sender.upperValue)
		actionChangeValue((sender.lowerValue, sender.upperValue))
	}
}
