//
//  Alerts.swift
//  Map
//
//  Created by Ekaterina Khudzhamkulova on 12.01.2020.
//

import UIKit

enum Alerts
{
	typealias Action = () -> Void

	private static func showBasicAlert(on vc: UIViewController,
									   with title: String,
									   message: String,
									   handler: @escaping Action) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
			handler()
		})
		vc.present(alert, animated: true)
	}

	private static func showSheetAlert(on vc: UIViewController,
									   with title: String,
									   removeHandler: @escaping Action,
									   cancelChangesHandler: @escaping Action,
									   cancelHandler: @escaping Action) {
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

	static func showDeletePinAlert(on vc: UIViewController, handler: @escaping Action) {
		showBasicAlert(on: vc, with: "Внимание", message: "Повторное действие удалит сохраненную локацию", handler: handler)
	}

	static func showActionsForPinAlert(on vc: UIViewController,
									   removeHandler: @escaping Action,
									   cancelChangesHandler: @escaping Action,
									   cancelHandler: @escaping Action) {
		showSheetAlert(on: vc,
					   with: "Выберите действие",
					   removeHandler: removeHandler,
					   cancelChangesHandler: cancelChangesHandler,
					   cancelHandler: cancelHandler)
	}
}
