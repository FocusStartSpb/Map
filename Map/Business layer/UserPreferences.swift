//
//  UserPreferences.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

// swiftlint:disable let_var_whitespace
enum UserPreferences
{
	enum MeasuringSystem: String
	{
		case mile, kilometer
	}

	enum Sorting: String
	{
		case data, address, title
	}

	@SettingWrapper(key: Key[.measuringSystem], defaultValue: MeasuringSystem.kilometer.rawValue)
	private static var _measuringSystem: String?

	/// Setting Measuring System
	static var measuringSystem: MeasuringSystem? {
		set { _measuringSystem = newValue?.rawValue }
		get { MeasuringSystem(rawValue: _measuringSystem ?? "") }
	}

	@SettingWrapper(key: Key[.sorting], defaultValue: Sorting.data.rawValue)
	private static var _sorting: String?
	/// Sorting by in table
	static var sorting: Sorting? {
		set { _sorting = newValue?.rawValue }
		get { Sorting(rawValue: _sorting ?? "") }
	}

	/// Ask for confidence when removing Smart Target
	@SettingWrapper(key: Key[.forceRemovePin], defaultValue: false)
	static var forceRemovePin: Bool?

	private enum Key: String, CaseIterable
	{
		case measuringSystem
		case sorting
		case forceRemovePin

		static subscript(key: Self) -> String {
			key.rawValue
		}
	}

	/// Return to default settings
	func removeUserInfo() {
		Key.allCases.forEach { key in
			SettingWrapper<Any>(key: key.rawValue).removeValue()
		}
	}
}
