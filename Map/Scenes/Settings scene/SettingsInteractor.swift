//
//  SettingsInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 30.12.2019.
//

// MARK: - SettingsBusinessLogic protocol
protocol SettingsBusinessLogic
{
	func doSomething(request: Settings.Something.Request)
}

// MARK: - Class
final class SettingsInteractor
{
	// MARK: ...Private properties
	private var presenter: SettingsPresentationLogic?
	private var worker: SettingsWorker?

	// MARK: ...Initialization
	init(presenter: SettingsPresentationLogic, worker: SettingsWorker) {
		self.presenter = presenter
		self.worker = worker
	}
}

// MARK: - Settings business logic Protocol
extension SettingsInteractor: SettingsBusinessLogic
{
	func doSomething(request: Settings.Something.Request) {
	}
}
