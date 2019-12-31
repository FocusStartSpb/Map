//
//  RangeSliderTrackLayer.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class RangeSliderTrackLayer: CALayer
{
	weak var rangeSlider: RangeSlider?

	override func draw(in ctx: CGContext) {
		guard let slider = rangeSlider else { return }
		// Clip
		let cornerRadius = bounds.height * slider.curvaceousness / 2.0
		let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

		ctx.addPath(path.cgPath)

		// Fill the track
		ctx.setFillColor(slider.trackTintColor.cgColor)
		ctx.addPath(path.cgPath)
		ctx.fillPath()

		// Fill the highlighted range
		ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
		let lowerValuePosition = CGFloat(slider.position(for: slider.lowerValue))
		let upperValuePosition = CGFloat(slider.position(for: slider.upperValue))
		let rect = CGRect(x: lowerValuePosition,
						  y: 0,
						  width: upperValuePosition - lowerValuePosition,
						  height: bounds.height)
		ctx.fill(rect)
	}
}
