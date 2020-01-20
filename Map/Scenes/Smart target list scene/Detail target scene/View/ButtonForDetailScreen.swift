//
//  ButtonForDetailScreen.swift
//  Map
//
//  Created by Anton on 10.01.2020.
//

import UIKit

final class ButtonForDetailScreen: UIButton
{
	private let currentBackground: UIColor

	init(backgroundColor: UIColor, frame: CGRect) {
		self.currentBackground = backgroundColor
		super.init(frame: frame)
		self.backgroundColor = backgroundColor
		setupUI()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			if self.isHighlighted {
				UIView.animate(withDuration: 0.3, animations: {
					self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.8).cgColor
				})
			}
			else {
				UIView.animate(withDuration: 0.3, animations: {
					self.layer.backgroundColor = self.currentBackground.cgColor
				})
			}
		}
	}

	func reset(title: String) {
		self.setTitle(title, for: .normal)
		self.backgroundColor = currentBackground
		self.isEnabled = true
	}

	private func setupUI() {
		self.layer.shadowOffset = CGSize(width: self.bounds.width, height: self.bounds.height + 7)
		self.layer.shadowRadius = 0.5
		self.layer.shadowOpacity = 0.3
		self.layer.cornerRadius = 12
	}
}
