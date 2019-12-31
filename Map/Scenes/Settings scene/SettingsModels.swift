//
//  SettingsModels.swift
//
//  Settings.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

// swiftlint:disable nesting
enum Settings
{
	// MARK: ...Use cases

	// MARK: ...SegmentedControl
	enum SegmentedControl
	{
		struct Request
		{
			let typeItems: UserPreferences.Key
		}

		struct Response
		{
			let typeItems: UserPreferences.Key
			let items: [String]
			let selectedItem: String
		}

		struct ViewModel
		{
			let title: String
			let typeItems: UserPreferences.Key
			let items: [String]
			let selectedItem: Int
		}
	}

	// MARK: ...Switch
	enum Switch
	{
		struct Request
		{
			let typeItems: UserPreferences.Key
		}

		struct Response
		{
			let typeItems: UserPreferences.Key
			let isOn: Bool
		}

		struct ViewModel
		{
			let title: String
			let typeItems: UserPreferences.Key
			let isOn: Bool
		}
	}

	// MARK: ...RangeSlider
	enum RangeSlider
	{
		struct Request
		{
			let typeItems: UserPreferences.Key
		}

		struct Response
		{
			let typeItems: UserPreferences.Key
			let range: Double
			let rangeValues: (min: Double, max: Double)
			let userValues: (lower: Double, upper: Double)
		}

		struct ViewModel
		{
			let title: String
			let typeItems: UserPreferences.Key
			let range: Double
			let rangeValues: (min: Double, max: Double)
			let userValues: (lower: Double, upper: Double)
		}
	}

	// MARK: ...ChangeValueSegmentedControl
	enum ChangeValueSegmentedControl
	{
		struct Request
		{
			let value: String
			let typeItems: UserPreferences.Key
		}

		struct Response
		{
			let isChanged: Bool
		}

		struct ViewModel
		{
			let isChanged: Bool
		}
	}

	// MARK: ...ChangeValueSwitch
	enum ChangeValueSwitch
	{
		struct Request
		{
			let value: Bool
			let typeItems: UserPreferences.Key
		}

		struct Response
		{
			let isChanged: Bool
		}

		struct ViewModel
		{
			let isChanged: Bool
		}
	}

	// MARK: ...ChangeValueRangeSlider
	enum ChangeValueRangeSlider
	{
		struct Request
		{
			let values: (lower: Double, upper: Double)
			let typeItems: UserPreferences.Key
		}

		struct Response
		{
			let isChanged: Bool
		}

		struct ViewModel
		{
			let isChanged: Bool
		}
	}
}
