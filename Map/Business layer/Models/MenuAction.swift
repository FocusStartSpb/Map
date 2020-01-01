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
	let handler: ((MenuAction) -> Void)?

	init(title: String?, style: UIAlertAction.Style, handler: ((MenuAction) -> Void)?) {
		self.title = title
		self.style = style
		self.handler = handler
	}

	static func == (lhs: MenuAction, rhs: MenuAction) -> Bool {
		lhs.title == rhs.title
	}
}
