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
	enum SaveSmartTargets
	{
		struct Request
		{
			let smartTargetCollection: SmartTargetCollection
		}

		struct Response
		{
			let result: SmartTargetsResult
		}

		struct ViewModel
		{
			let didSave: Bool
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
			let addedIndexPaths: [IndexPath]
			let removedIndexPaths: [IndexPath]
			let updatedIndexPaths: [IndexPath]
		}
	}
}
