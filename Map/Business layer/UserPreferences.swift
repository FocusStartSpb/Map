//
//  UserPreferences.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

// swiftlint:disable let_var_whitespace
enum UserPreferences
{
	enum MeasuringSystem: String, CaseIterable
	{
		case mile, kilometer
	}

	enum Sorting: String, CaseIterable
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
	@SettingWrapper(key: Key[.forceRemovePin], defaultValue: true)
	static var forceRemovePin: Bool?

	/// Minimum range between lowerValueOfRadius and upperValueOfRadius in meters
	@SettingWrapper(key: Key[.minRangeOfRadius], defaultValue: Constants.Radius.defaultMinimumRange)
	static var minRangeOfRadius: Double?

	/// Minimum possible radius value in meters
	@SettingWrapper(key: Key[.minValueOfRadius], defaultValue: Constants.Radius.defaultMinimumValue)
	static var minValueOfRadius: Double?

	/// Maximum possible radius value in meters
	@SettingWrapper(key: Key[.maxValueOfRadius], defaultValue: Constants.Radius.defaultMaximumValue)
	static var maxValueOfRadius: Double?

	/// Minimum radius value in meters set by user
	@SettingWrapper(key: Key[.lowerValueOfRadius], defaultValue: Constants.Radius.defaultLowerValue)
	static var lowerValueOfRadius: Double?

	/// Maximum radius value in meters set by user
	@SettingWrapper(key: Key[.upperValueOfRadius], defaultValue: Constants.Radius.defaultUpperValue)
	static var upperValueOfRadius: Double?

	enum Key: String, CaseIterable
	{
		case measuringSystem
		case sorting
		case forceRemovePin
		case minRangeOfRadius
		case minValueOfRadius
		case maxValueOfRadius
		case lowerValueOfRadius
		case upperValueOfRadius

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
