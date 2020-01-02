//
//  SmartTargetCollection.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 20.12.2019.
//

import Foundation

// MARK: - ISmartTargetCollection protocol
protocol ISmartTargetCollection: Codable
{
	var count: Int { get }
	var smartTargets: [SmartTarget] { get }

	@discardableResult func put(_ smartTarget: SmartTarget) -> Int
	func add(_ smartTargets: [SmartTarget])
	@discardableResult func remove(atUID uid: String) -> Int?
	func smartTarget(at uid: String) -> SmartTarget?
	func smartTargets(at uids: [String]) -> [SmartTarget]
	func index(at uid: String) -> Int?
	func index(at smartTarget: SmartTarget) -> Int?
	func indexes(at uids: [String]) -> [Int]
	func indexes(at smartTargets: [SmartTarget]) -> [Int]
	subscript(_ uid: String) -> SmartTarget? { get }

	func smartTargetsOfDifference(from other: ISmartTargetCollection) ->
		(added: [SmartTarget], removed: [SmartTarget], updated: [SmartTarget])

	func copy() -> Self
}

// MARK: - Class
final class SmartTargetCollection
{

	// MARK: ...Initializations
	convenience init(_ smartTargets: [SmartTarget]) {
		self.init()
		self.add(smartTargets)
	}

	// MARK: ...Properties
	private(set) var smartTargets = [SmartTarget]()
}

// MARK: - ISmartTargetCollection
extension SmartTargetCollection: ISmartTargetCollection
{

	// MARK: ...Public methods

	/// Add smart target to first position or replace.
	/// - Parameter smartTarget: added smart target
	/// - Return: index at added smart target
	@discardableResult func put(_ smartTarget: SmartTarget) -> Int {
		guard let index = smartTargets.firstIndex(of: smartTarget) else {
			smartTargets.insert(smartTarget, at: 0)
			return 0
		}
		smartTargets[index] = smartTarget
		return index
	}

	/// Add smart targets to the end of the array
	/// - Parameter smartTarget: added smart targets
	func add(_ smartTargets: [SmartTarget]) {
		self.smartTargets += smartTargets
		self.smartTargets.removeDuplicates()
	}

	/// Remove smart target from array
	/// - Parameter uid: removed smart target at uid
	@discardableResult func remove(atUID uid: String) -> Int? {
		guard let index = smartTargets.firstIndex(where: { $0.uid == uid }) else { return nil }
		smartTargets.remove(at: index)
		return index
	}

	func smartTarget(at uid: String) -> SmartTarget? {
		smartTargets.first { $0.uid == uid }
	}

	func smartTargets(at uids: [String]) -> [SmartTarget] {
		uids.reduce(into: []) { $0.append(self[$1]) }
			.compactMap { $0 }
	}

	func index(at uid: String) -> Int? {
		smartTargets.firstIndex { $0.uid == uid }
	}

	func index(at smartTarget: SmartTarget) -> Int? {
		index(at: smartTarget.uid)
	}

	func indexes(at uids: [String]) -> [Int] {
		smartTargets(at: uids)
			.reduce(into: []) { $0.append(smartTargets.firstIndex(of: $1)) }
			.compactMap { $0 }
	}

	func indexes(at smartTargets: [SmartTarget]) -> [Int] {
		indexes(at: smartTargets.map { $0.uid })
	}

	subscript(_ uid: String) -> SmartTarget? {
		smartTarget(at: uid)
	}

	func smartTargetsOfDifference(from other: ISmartTargetCollection) ->
		(added: [SmartTarget], removed: [SmartTarget], updated: [SmartTarget]) {

		let otherSmartTargets = other.smartTargets
		let difference = smartTargets.difference(from: otherSmartTargets)
		return difference
			.reduce(into: (added: [SmartTarget](), removed: [SmartTarget](), updated: [SmartTarget]())) { result, smartTarget in
				if let dif = otherSmartTargets.first(where: { $0 == smartTarget }) {
					if let same = smartTargets.first(where: { dif == $0 }) {
						if same !== smartTarget {
							result.updated.append(smartTarget)
						}
					}
					else {
						result.removed.append(smartTarget)
					}
				}
				else if let dif = smartTargets.first(where: { $0 == smartTarget }),
					otherSmartTargets.contains(dif) == false {

					result.added.append(smartTarget)
				}
			}
	}

	var count: Int { smartTargets.count }

	func copy() -> Self {
		Self(smartTargets)
	}

	static func += (lhs: SmartTargetCollection, rhs: SmartTarget) {
		lhs.put(rhs)
	}

	static func += (lhs: SmartTargetCollection, rhs: [SmartTarget]) {
		lhs.add(rhs)
	}
}

// MARK: - Custom string convertible
extension SmartTargetCollection: CustomStringConvertible
{
	var description: String { smartTargets.description }
}
