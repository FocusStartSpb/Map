//
//  SmartTargetListModels.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import Foundation

// swiftlint:disable nesting
enum SmartTargetList
{
	// MARK: Use cases

	// MARK: ...LoadSmartTargets
	enum LoadSmartTargets
	{
		struct Request
		{
		}

		struct Response
		{
			let result: SmartTargetsResult
		}

		struct ViewModel
		{
			let didLoad: Bool
		}
	}

	// MARK: ...SaveSmartTargets
	enum DeleteSmartTargets
	{
		struct Request
		{
			let smartTargetsIndexSet: IndexSet
		}

		struct Response
		{
			let result: SmartTargetsResult
		}

		struct ViewModel
		{
			let didDelete: Bool
		}
	}

	// MARK: ...UpdateSmartTargets
	enum UpdateSmartTargets
	{
		struct Request { }

		struct Response
		{
			let collection: ISmartTargetCollection
			let addedSmartTargets: [SmartTarget]
			let removedSmartTargets: [SmartTarget]
			let updatedSmartTargets: [SmartTarget]
		}

		struct ViewModel
		{
			let addedIndexSet: IndexSet
			let removedIndexSet: IndexSet
			let updatedIndexSet: IndexSet
		}
	}

	enum UpdateSmartTarget
	{
		struct Request {}

		struct Response
		{
			let editedSmartTargetIndex: Int
		}

		struct ViewModel
		{
			let updatedIndexSet: IndexSet
		}
	}
}
