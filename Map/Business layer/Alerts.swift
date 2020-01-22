//
//  Alerts.swift
//  Map
//
//  Created by Ekaterina Khudzhamkulova on 12.01.2020.
//

import UIKit

enum Alerts
{
	private static func showBasicAlert(on vc: UIViewController,
									   with title: String,
									   message: String,
									   handler: @escaping TapAction) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
			handler()
		})
		vc.present(alert, animated: true)
	}

	private static func showSheetAlert(on vc: UIViewController,
									   with title: String,
									   removeHandler: @escaping TapAction,
									   cancelChangesHandler: @escaping TapAction,
									   cancelHandler: @escaping TapAction) {
		let alert = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
		let removeAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
			removeHandler()
		}
		let cancelChangesAction = UIAlertAction(title: "Отменить изменения", style: .default) { _ in
			cancelChangesHandler()
		}
		let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
			cancelHandler()
		}
		alert.addAction(removeAction)
		alert.addAction(cancelChangesAction)
		alert.addAction(cancelAction)
		vc.present(alert, animated: true)
	}

	static func showDeletePinAlert(on vc: UIViewController, handler: @escaping TapAction) {
		showBasicAlert(on: vc, with: "Внимание", message: "Повторное действие удалит сохраненную локацию", handler: handler)
	}

	static func showMaxSmartTargetsAlert(on vc: UIViewController, handler: @escaping TapAction) {
		showBasicAlert(on: vc, with: "Внимание",
					   message: """
								Превышен лимит созданных локаций.
								Пожалуйста удалите какую-нибудь локацию, чтобы создать новую.
								""",
					   handler: handler)
	}

	static func showActionsForPinAlert(on vc: UIViewController,
									   removeHandler: @escaping TapAction,
									   cancelChangesHandler: @escaping TapAction,
									   cancelHandler: @escaping TapAction) {
		showSheetAlert(on: vc,
					   with: "Выберите действие",
					   removeHandler: removeHandler,
					   cancelChangesHandler: cancelChangesHandler,
					   cancelHandler: cancelHandler)
	}
}
