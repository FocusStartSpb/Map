//
//  UIView.swift
//  Map
//
//  Created by Anton on 20.01.2020.
//

import UIKit

extension UIView
{
	var userInterfaceStyleIsDark: Bool {
		if #available (iOS 13.0, *) {
			if traitCollection.userInterfaceStyle == .dark {
				return true
			}
			else {
				return false
			}
		}
		else {
			return false
		}
	}
}
