//
//  SettingsPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

// MARK: - SettingsPresentationLogic protocol
protocol SettingsPresentationLogic
{
	func presentSomething(response: Settings.Something.Response)
}

// MARK: - Class
final class SettingsPresenter
{
	// MARK: ...Internal properties
	weak var viewController: SettingsDisplayLogic?
}

// MARK: - Settings presentation logic protocol
extension SettingsPresenter: SettingsPresentationLogic
{
	func presentSomething(response: Settings.Something.Response) {
	}
}
