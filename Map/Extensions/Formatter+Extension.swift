//
//  Formatter+Extension.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 09.01.2020.
//

import Foundation

extension Formatter
{
	static let medium: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		formatter.locale = Locale.current
		return formatter
	}()

	static let full: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss"
		formatter.locale = Locale.current
		return formatter
	}()
}
