//
//  DataBaseServicce.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 19.12.2019.
//

import Foundation

// MARK: - Class
final class DataBaseService<Element: Codable>
{
	private enum Path: String
	{
		case component = "Element_Dictionary"
		case `extension` = "plist"
	}

	// MARK: ...Private static properties
	private let fileManager = FilesManager()

	// MARK: ...Methods
	/// Write to file
	func write(_ element: Element) throws {
		do {
			let data = try JSONEncoder().encode(element)
			try fileManager.save(fileNamed: Path.component.rawValue,
								 extension: Path.extension.rawValue,
								 data: data,
								 overwrite: true)
		}
		catch {
			throw error
		}
	}

	/// Read from file
	func read() throws -> Element {
		do {
			let data = try fileManager.read(fileNamed: Path.component.rawValue,
											extension: Path.extension.rawValue)
			return try Element(data: data, decoder: JSONDecoder())
		}
		catch {
			throw error
		}
	}
}
