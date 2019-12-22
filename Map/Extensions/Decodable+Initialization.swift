//
//  Decodable+Initialization.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 21.12.2019.
//

import Foundation

extension Decodable
{
	init(data: Data, decoder: JSONDecoder) throws {
		do {
			self = try decoder.decode(Self.self, from: data)
		}
		catch {
			throw error
		}
	}
}
