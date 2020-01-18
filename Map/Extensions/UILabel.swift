//
//  UILabel.swift
//  Map
//
//  Created by Anton on 17.01.2020.
//

import UIKit

extension UILabel
{
	func setTextAnimation(string: String) {
		var newText = ""
		UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve, animations: {
			string.forEach{
				newText += "\($0)"
				self.text = newText
			}
		})
	}
}
