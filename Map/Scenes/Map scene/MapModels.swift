//
//  MapModels.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// swiftlint:disable nesting
enum Map
{
	// MARK: Use cases

	// MARK: ...SmartTargets
	enum SmartTargets
	{
		struct Request
		{
		}

		struct Response
		{
			let smartTargetCollection: ISmartTargetCollection
		}

		struct ViewModel
		{
			let smartTargetCollection: ISmartTargetCollection
		}
	}
}
