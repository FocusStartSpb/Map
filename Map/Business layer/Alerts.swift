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
									   handler: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
			handler()
		})
		vc.present(alert, animated: true)
	}

	private static func showSheetAlert(on vc: UIViewController,
										with title: String,
										removeHandler: @escaping () -> Void,
										cancelChangesHandler: @escaping () -> Void,
										cancelHandler: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
		let removeAction = UIAlertAction(title: "Remove",
										 style: .destructive) { _ in
											removeHandler()
		}
		let cancelChangesAction = UIAlertAction(title: "Cancel changes",
												style: .default) { _ in
													cancelChangesHandler()
		}
		let cancelAction = UIAlertAction(title: "Cancel",
										 style: .cancel) { _ in
											cancelHandler()
		}
		alert.addAction(removeAction)
		alert.addAction(cancelChangesAction)
		alert.addAction(cancelAction)
		vc.present(alert, animated: true)
	}

	static func showDeletePinAlert(on vc: UIViewController, handler: @escaping () -> Void) {
		showBasicAlert(on: vc, with: "Внимание", message: "Повторное действие удалит сохраненную локацию", handler: handler)
	}

	static func showActionsForPinAlert(on vc: UIViewController,
									   removeHandler: @escaping () -> Void,
									   cancelChangesHandler: @escaping () -> Void,
									   cancelHandler: @escaping () -> Void) {
		showSheetAlert(on: vc,
					   with: "Выберите действие",
					   removeHandler: removeHandler,
					   cancelChangesHandler: cancelChangesHandler,
					   cancelHandler: cancelHandler)
	}
}
