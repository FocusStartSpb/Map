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
			let smartTargets: [SmartTarget]
		}

		struct ViewModel
		{
			let smartTargets: [SmartTarget]
		}
	}
}
