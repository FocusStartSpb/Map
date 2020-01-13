//
//  Alerts.swift
//  Map
//
//  Created by Ekaterina Khudzhamkulova on 12.01.2020.
//

import UIKit

enum Alerts
{
	private static func showBasicAlert(on vc: UIViewController, with title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		vc.present(alert, animated: true)
	}

	static func showDeletePinAlert(on vc: UIViewController) {
		showBasicAlert(on: vc, with: "Внимание", message: "Повторное действие удалит сохраненную локацию")
	}
}
