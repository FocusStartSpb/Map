//
//  Array+Difference.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 02.01.2020.
//

extension Array where Element: Hashable
{
	func difference(from other: [Element]) -> [Element] {
		let thisSet = Set(self)
		let otherSet = Set(other)
		return Array(thisSet.symmetricDifference(otherSet))
	}
}

extension Array where Element: Hashable & Identity
{
	func difference(from other: [Element]) -> [Element] {
		let thisSet = Set(self)
		let otherSet = Set(other)
		print((self + other).uniqueElements)
		let newFromThisSet = thisSet.reduce(into: [Element]()) { result, element in
			if otherSet.contains(where: { element === $0 }) == false {
				result.append(element)
			}
		}
		let newFromOtherSet = otherSet.reduce(into: [Element]()) { result, element in
			if thisSet.contains(where: { element === $0 }) == false {
				result.append(element)
			}
		}
		return Array(newFromThisSet + newFromOtherSet)
	}
}
