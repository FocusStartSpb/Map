//
//  RangeSliderThumbLayer.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import UIKit

final class RangeSliderThumbLayer: CALayer
{
	var highlighted: Bool = false {
		didSet {
			setNeedsDisplay()
		}
	}

	weak var rangeSlider: RangeSlider?

	override func draw(in ctx: CGContext) {
		guard let slider = rangeSlider else { return }
		let thumbFrame = bounds.insetBy(dx: 2, dy: 2)
		let cornerRadius = thumbFrame.height * slider.curvaceousness / 2
		let thumbPath = UIBezierPath(roundedRect: thumbFrame,
									 cornerRadius: cornerRadius)

		// Fill - with a subtle shadow
		let shadowColor: UIColor
		if #available(iOS 13.0, *) {
			shadowColor = .systemFill
		}
		else {
			shadowColor = .gray
		}
		ctx.setShadow(offset: CGSize(width: 0, height: 2),
					  blur: 1,
					  color: shadowColor.cgColor)
		ctx.setFillColor(slider.thumbTintColor.cgColor)
		ctx.addPath(thumbPath.cgPath)
		ctx.fillPath()

			// Outline
		ctx.setStrokeColor(shadowColor.cgColor)
		ctx.setLineWidth(0.2)
		ctx.addPath(thumbPath.cgPath)
		ctx.strokePath()

		if highlighted {
			ctx.setFillColor(UIColor(white: 0, alpha: 0.1).cgColor)
			ctx.addPath(thumbPath.cgPath)
			ctx.fillPath()
		}
	}
}
