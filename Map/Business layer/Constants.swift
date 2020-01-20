//
//  Constants.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//
// swiftlint:disable nesting

import CoreLocation
import UIKit

enum Constants
{
	static let maxLenghtOfTitle = 30

	enum MeasurementSystem
	{
		enum Symbol
		{
			static let imperial = "фт"
			static let metric = "м"
		}
	}

	enum Radius
	{
		static let defaultValue: CLLocationDistance = 300
		static let defaultMinimumValue: CLLocationDistance = 100
		static let defaultMaximumValue: CLLocationDistance = 5_000
		static let defaultMinimumRange: CLLocationDistance = 700
		static let defaultLowerValue: CLLocationDistance = 300
		static let defaultUpperValue: CLLocationDistance = 1_000
	}

	enum Distance
	{
		static let latitudalMeters: CLLocationDistance = 5_000
		static let longtitudalMeters: CLLocationDistance = 5_000
	}

	enum Size
	{
		static let mapButton: CGFloat = 40
	}

	enum Offset
	{
		static let mapButton: CGFloat = 20
	}

	enum CircularMapOverlay
	{
		static let fillColorForUserInside = UIColor.systemBlue.withAlphaComponent(0.5)
		static let fillColorForUserOutside: UIColor = {
			if #available(iOS 13.0, *) {
				return UIColor.systemBackground.withAlphaComponent(0.5)
			}
			else {
				return UIColor.white.withAlphaComponent(0.5)
			}
		}()
		static let strokeColor: UIColor = .systemBlue
		static let lineWidth: CGFloat = 1
	}

	enum ImpactFeedbackGeneratorStyle
	{
		static let dropPin: UIImpactFeedbackGenerator.FeedbackStyle = {
			if #available(iOS 13.0, *) {
				return .soft
			}
			else {
				return .light
			}
		}()
	}

	enum ScreenProperties
	{
		static let width = UIScreen.main.bounds.width
		static let height = UIScreen.main.bounds.height
	}

	enum Colors
	{
		static let selectedCellBackgroundColorInDarkMode = #colorLiteral(red: 0.3045190282, green: 0.3114352223, blue: 0.3184640712, alpha: 1)
		static let tableViewBackgroundColorInDarkMode = #colorLiteral(red: 0.2204069229, green: 0.2313892178, blue: 0.253805164, alpha: 1)
		static let viewBackgroundColorInDarkMode = #colorLiteral(red: 0.2204069229, green: 0.2313892178, blue: 0.253805164, alpha: 1)
		static let navigationBarTintColorInDarkMode = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
		static let selectedCellBackgroundColorInLightMode = #colorLiteral(red: 0.7502671557, green: 0.7502671557, blue: 0.7502671557, alpha: 1)
		static let viewBackgroundColorInLightMode = UIColor.white
		static let tableViewBackgroundColorInLightMode = #colorLiteral(red: 0.9871620841, green: 0.9871620841, blue: 0.9871620841, alpha: 1)
		static let navigationBarTintColorInLightMode = UIColor.white
	}

	enum Fonts
	{
		enum ForCells
		{
			static let timeOfCreation = UIFont.systemFont(ofSize: 15, weight: .light)
			static let titleLabel = UIFont.systemFont(ofSize: 20, weight: .bold)
			static let addressLabel = UIFont.systemFont(ofSize: 20, weight: .regular)
		}

		enum ForDetailScreen
		{
			static let titleTextView = UIFont.systemFont(ofSize: 25, weight: .semibold)
			static let dateOfCreationLabel = UIFont.systemFont(ofSize: 20, weight: .light)
			static let addressLabel = UIFont.systemFont(ofSize: 20, weight: .light)
			static let attendanceLabels = UIFont.systemFont(ofSize: 20, weight: .light)
		}
	}

	static let activityIndicatorStyle: UIActivityIndicatorView.Style = {
		if #available(iOS 13.0, *) {
			return .medium
		}
		else {
			return .gray
		}
	}()
}
