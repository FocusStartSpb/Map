//
//  FilesManager.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

import Foundation

final class FilesManager
{
	private let fileManager: FileManager = .default

	enum Error: Swift.Error
	{
		case fileAlreadyExists
		case invalidDirectory
		case writtingFailed
		case fileNotExists
		case readingFailed
	}

	func save(fileNamed: String, extension: String, data: Data, overwrite: Bool = true) throws {
		guard let url = url(forFileNamed: fileNamed, extension: `extension`) else {
			throw Error.invalidDirectory
		}
		if overwrite == false, fileManager.fileExists(atPath: url.path) {
			throw Error.fileAlreadyExists
		}
		do {
			try data.write(to: url)
		}
		catch {
			throw Error.writtingFailed
		}
	}

	func read(fileNamed: String, extension: String) throws -> Data {
		guard let url = url(forFileNamed: fileNamed, extension: `extension`) else {
			throw Error.invalidDirectory
		}
		guard fileManager.fileExists(atPath: url.path) else {
			throw Error.fileNotExists
		}
		do {
			return try Data(contentsOf: url)
		}
		catch {
			throw Error.readingFailed
		}
	}
}

private extension FilesManager
{
	private func url(forFileNamed fileName: String, extension: String) -> URL? {
		try? fileManager
			.url(for: .documentDirectory,
				 in: .userDomainMask,
				 appropriateFor: nil,
				 create: true)
			.appendingPathComponent(fileName)
			.appendingPathExtension(`extension`)
	}
}
