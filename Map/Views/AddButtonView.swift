//
//  AddButtonView.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 24.12.2019.
//

import UIKit

typealias TapAction = () -> Void

final class AddButtonView: UIView
{

	// MARK: ...Private properties
	private var tapAction: TapAction?

	private let blurredView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .light)
		let view = UIVisualEffectView(effect: blurEffect)
		return view
	}()

	private let vibrancyView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .prominent)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let view = UIVisualEffectView(effect: vibrancyEffect)
		return view
	}()

	private let addButton: UIButton = {
		let button = UIButton()
		button.layer.cornerRadius = 10
		button.setTitleColor(.systemRed, for: .normal)
		if #available(iOS 13.0, *) {
			button.setImage(#imageLiteral(resourceName: "icons-add").withTintColor(.systemBackground), for: .normal)
			if let darkerColor = UIColor.systemBackground.darker() {
				button.setImage(#imageLiteral(resourceName: "icons-add").withTintColor(darkerColor), for: .highlighted)
			}
		}
		else {
			button.setImage(#imageLiteral(resourceName: "icons-add"), for: .normal)
		}
		button.addTarget(self, action: #selector(actionTap), for: .touchUpInside)
		return button
	}()

	// MARK: ...Initialization
	init() {
		super.init(frame: .zero)

		setup()
	}

	convenience init(tapAction: @escaping TapAction) {
		self.init()
		self.addAction(tapAction)
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...Private methods
	private func setup() {

		// Set corner radius
		layer.cornerRadius = 10
		self.clipsToBounds = true

		// Add subviews
		addSubview(blurredView)

		// Set blurred effect view
		vibrancyView.contentView.addSubview(addButton)
		blurredView.contentView.addSubview(vibrancyView)

		setConstraints()
	}

	private func setConstraints() {
		vibrancyView.translatesAutoresizingMaskIntoConstraints = false
		blurredView.translatesAutoresizingMaskIntoConstraints = false
		addButton.translatesAutoresizingMaskIntoConstraints = false

		// Set constraint for addButton
		addButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		addButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
		addButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		addButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		// Set constraint for blurredView
		blurredView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		blurredView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		blurredView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		blurredView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		// Set constraint for vibrancyView
		vibrancyView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		vibrancyView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		vibrancyView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		vibrancyView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}

	// MARK: ...Methods
	func addAction(_ action: @escaping TapAction) {
		tapAction = action
	}
}

// MARK: - Actions
@objc extension AddButtonView
{
	private func actionTap() {
		tapAction?()
	}
}
