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
			let difference: Difference
		}

		struct ViewModel
		{
			let needUpdate: Bool
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
			let editedSmartTarget: SmartTarget
			let oldSmartTarget: SmartTarget
			let editedSmartTargetIndex: Int
		}

		struct ViewModel
		{
			let needUpdate: Bool
			let updatedIndexSet: IndexSet
		}
	}

	enum ShowEmptyView
	{
		struct Request {}

		struct Response
		{
			let showEmptyView: Bool
		}

		struct ViewModel
		{
			let showEmptyView: Bool
		}
	}
}
