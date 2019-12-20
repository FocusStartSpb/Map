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
	private static var url: URL? {
		FileManager
			.default
			.urls(for: .documentDirectory, in: .userDomainMask)
			.first?
			.appendingPathComponent(Path.component.rawValue)
			.appendingPathExtension(Path.extension.rawValue)
	}

	// MARK: ...Methods
	/// Write to file
	func write(_ element: Element) throws {
		do {
			guard let url = Self.url else {
				throw ServiceError.canNotSaveSmartTarget(message: "Path error")
			}
			let data = try JSONEncoder().encode(element)
			try data.write(to: url, options: .noFileProtection)
		}
		catch {
			throw error
		}
	}

	/// Read from file
	func read() throws -> Element {
		do {
			guard let url = Self.url else {
				throw ServiceError.canNotLoadSmartTarget(message: "Path error")
			}
			let data = try Data(contentsOf: url)
			let elements = try JSONDecoder().decode(Element.self, from: data)
			return elements
		}
		catch {
			throw error
		}
	}
}
