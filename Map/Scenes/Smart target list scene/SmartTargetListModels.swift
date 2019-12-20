//
//  SmartTargetListModels.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// swiftlint:disable nesting
enum SmartTargetList
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
			let smartTargets: ISmartTargetCollection
		}

		struct ViewModel
		{
			let smartTargets: ISmartTargetCollection
		}
	}
}
