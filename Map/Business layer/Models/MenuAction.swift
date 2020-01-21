//
//  MenuAction.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 01.01.2020.
//

import UIKit

struct MenuAction: Equatable
{
	let title: String?
	let style: UIAlertAction.Style
	let handler: ((Self) -> Void)?

	init(title: String?, style: UIAlertAction.Style, handler: ((Self) -> Void)?) {
		self.title = title
		self.style = style
		self.handler = handler
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.title == rhs.title
	}
}
