//
//  DismissView.swift
//  Map
//
//  Created by Anton on 30.12.2019.
//

import UIKit

final class DismissView: UIView
{
	private let chevronDown = UIImageView(image: #imageLiteral(resourceName: "down-chevron"))

	override init(frame: CGRect) {
		super.init(frame: frame)
		chevronDownSetup()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func chevronDownSetup() {
		self.addSubview(chevronDown)
		self.chevronDown.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.chevronDown.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.chevronDown.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
			self.chevronDown.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.chevronDown.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
		self.chevronDown.contentMode = .scaleAspectFit
		self.chevronDown.backgroundColor = self.backgroundColor
		self.chevronDown.image = self.chevronDown.image?.withRenderingMode(.alwaysTemplate)
		self.chevronDown.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
	}
}
