//
//  EmptyView.swift
//  Map
//
//  Created by Anton on 16.01.2020.
//

import UIKit

protocol IEmptyView
{
	func pinToSuperview(superview: UIView)
	func leave()
}

final class EmptyView: UIView
{
	private let messageLabel: UILabel = {
		let label = UILabel()
		label.text =
		"""
		В данный момент у вас нет сохраненных локаций.
		Перейдите, пожалуйста, на вкладку с картой и создайте их.
		"""
		label.font = Constants.Fonts.ForEmptyView.labelFont
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 0
		label.minimumScaleFactor = 0.01
		label.textAlignment = .center
		return label
	}()

	private let sadTargetImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = #imageLiteral(resourceName: "sadTarget-1")
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let verticalStack = UIStackView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupVerticalStack()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupVerticalStack() {
		self.addSubview(verticalStack)
		verticalStack.addArrangedSubview(messageLabel)
		verticalStack.addArrangedSubview(sadTargetImageView)
		verticalStack.axis = .vertical
		verticalStack.alignment = .center
		verticalStack.distribution = .fillEqually
		verticalStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			verticalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			verticalStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			verticalStack.topAnchor.constraint(equalTo: self.topAnchor),
			verticalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
	}
}
extension EmptyView: IEmptyView
{
	func pinToSuperview(superview: UIView) {
		self.alpha = 0
		UIView.animate(withDuration: 0.3, animations: { self.alpha = 1 })
		superview.addSubview(self)
		self.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
			self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
			self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
			self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
		])
	}

	func leave() {
		UIView.animate(withDuration: 0.3, animations: { self.alpha = 0 }, completion: { _ in
			self.removeFromSuperview()
		})
	}
}
