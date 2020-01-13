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

	static func showDeletePinAlert(on vc: UIViewController, handler: @escaping () -> Void) {
		showBasicAlert(on: vc, with: "Внимание", message: "Повторное действие удалит сохраненную локацию", handler: handler)
	}
}
