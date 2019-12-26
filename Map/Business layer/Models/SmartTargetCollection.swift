//
//  SmartTargetCollection.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 20.12.2019.
//

// MARK: - ISmartTargetCollection protocol
protocol ISmartTargetCollection: Codable
{
	var smartTargets: [SmartTarget] { get }

	func put(_ smartTarget: SmartTarget) -> Int
	func add(_ smartTargets: [SmartTarget])
	func remove(atUID uid: String) -> Int?
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
}

// MARK: - Custom string convertible
extension SmartTargetCollection: CustomStringConvertible
{
	var description: String { smartTargets.description }
}
