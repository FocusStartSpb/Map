//
//  Sequence+UniqueElements.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 20.12.2019.
//

extension Sequence where Element: Equatable
{
	var uniqueElements: [Element] {
		reduce(into: []) { uniqueElements, element in
			if uniqueElements.contains(element) == false {
				uniqueElements.append(element)
			}
		}
	}

	mutating func removeDuplicates() {
		self = uniqueElements as? Self ?? self
	}
}
