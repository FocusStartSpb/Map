//
//  RangeSlider.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class RangeSlider: UIControl
{
	// MARK: ...Internal properties
	var minimumValue = 0.0 {
		didSet { updateLayerFrames() }
	}
	var maximumValue = 1.0 {
		didSet { updateLayerFrames() }
	}
	var lowerValue = 0.2 {
		didSet { updateLayerFrames() }
	}
	var upperValue = 0.8 {
		didSet { updateLayerFrames() }
	}
	var minRange = 0.0 {
		didSet { updateLayerFrames() }
	}

	var trackTintColor: UIColor = {
		if #available(iOS 13.0, *) {
			return .systemFill
		}
		else { return .systemGray }
		}() {
		didSet { updateLayerFrames() }
	}
	var trackHighlightTintColor = UIColor(red: 0, green: 0.45, blue: 0.94, alpha: 1) {
		didSet { updateLayerFrames() }
	}
	var thumbTintColor = UIColor.white {
		didSet { updateLayerFrames() }
	}

	var curvaceousness: CGFloat = 1 {
		didSet { updateLayerFrames() }
	}

	private let trackLayer = RangeSliderTrackLayer()
	private let lowerThumbLayer = RangeSliderThumbLayer()
	private let upperThumbLayer = RangeSliderThumbLayer()

	private var previousLocation = CGPoint()

	private var thumbWidth: CGFloat { bounds.height }

	override init(frame: CGRect) {
		super.init(frame: frame)

		clipsToBounds = false

		trackLayer.rangeSlider = self
		trackLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(trackLayer)

		lowerThumbLayer.rangeSlider = self
		lowerThumbLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(lowerThumbLayer)

		upperThumbLayer.rangeSlider = self
		upperThumbLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(upperThumbLayer)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override var frame: CGRect {
		didSet { updateLayerFrames() }
	}

	func updateLayerFrames() {
		trackLayer.frame = bounds.insetBy(dx: 0, dy: bounds.height / 2.2)
		trackLayer.setNeedsDisplay()

		let lowerThumbCenter = CGFloat(position(for: lowerValue))

		lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2,
									   y: 0,
									   width: thumbWidth,
									   height: thumbWidth)
		lowerThumbLayer.setNeedsDisplay()

		let upperThumbCenter = CGFloat(position(for: upperValue))
		upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2,
									   y: 0,
									   width: thumbWidth,
									   height: thumbWidth)
		upperThumbLayer.setNeedsDisplay()
	}

	func position(for value: Double) -> Double {
		Double(bounds.width - thumbWidth) * (value - minimumValue) / (maximumValue - minimumValue) + Double(thumbWidth / 2)
	}

	private func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
		min(max(value, lowerValue), upperValue)
	}

	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		previousLocation = touch.location(in: self)

		// Hit test the thumb layers
		if lowerThumbLayer.frame.contains(previousLocation) {
			lowerThumbLayer.highlighted = true
		}
		else if upperThumbLayer.frame.contains(previousLocation) {
			upperThumbLayer.highlighted = true
		}

		return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
	}

	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)

		// 1. Determine by how much the user has dragged
		let deltaLocation = Double(location.x - previousLocation.x)
		let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
		previousLocation = location

		// 2. Update the values
		if lowerThumbLayer.highlighted {
			lowerValue += deltaValue
			if upperValue - lowerValue < minRange {
				lowerValue = upperValue - minRange
			}
			else {
				lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
			}
		}
		else if upperThumbLayer.highlighted {
			upperValue += deltaValue
			if upperValue - lowerValue < minRange {
				upperValue = lowerValue + minRange
			}
			else {
				upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
			}
		}

		// 3. Update the UI
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		updateLayerFrames()

		CATransaction.commit()

		sendActions(for: .valueChanged)

		return true
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		lowerThumbLayer.highlighted = false
		upperThumbLayer.highlighted = false
	}
}
