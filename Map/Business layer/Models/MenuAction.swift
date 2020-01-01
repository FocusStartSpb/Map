//
//  MenuAction.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 01.01.2020.
//

import UIKit

struct MenuAction
{
	let title: String?
	let style: UIAlertAction.Style
	let handler: ((MenuAction) -> Void)?

	init(title: String?, style: UIAlertAction.Style, handler: ((MenuAction) -> Void)?) {
		self.title = title
		self.style = style
		self.handler = handler
	}
}
