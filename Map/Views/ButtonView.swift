//
//  ButtonView.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 24.12.2019.
//

import UIKit

typealias TapAction = () -> Void

final class ButtonView: UIView
{

	enum `Type`
	{
		case add, currentLocation
	}

	// MARK: ...Private properties
	private let type: Type
	private var tapAction: TapAction?

	private let blurredView: UIVisualEffectView = {
		let style: UIBlurEffect.Style
		if #available(iOS 13.0, *) {
			style = .systemUltraThinMaterial
		}
		else {
			style = .light
		}
		let blurEffect = UIBlurEffect(style: style)
		let view = UIVisualEffectView(effect: blurEffect)
		return view
	}()

	private let vibrancyView: UIVisualEffectView = {
		let style: UIBlurEffect.Style
		if #available(iOS 13.0, *) {
			style = .systemThickMaterial
		}
		else {
			style = .prominent
		}
		let blurEffect = UIBlurEffect(style: style)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let view = UIVisualEffectView(effect: vibrancyEffect)
		return view
	}()

	private lazy var addButton: UIButton = {
		let button = UIButton()
		if #available(iOS 13.0, *) {
			button.setImage(type.image(for: .normal).withTintColor(.systemFill),
							for: .normal)
			button.setImage(type.image(for: .highlighted).withTintColor(.systemFill),
							for: .highlighted)
		}
		else {
			button.setImage(type.image(for: .normal), for: .normal)
			button.setImage(type.image(for: .highlighted), for: .highlighted)
		}
		button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
		button.addTarget(self, action: #selector(actionTap), for: .touchUpInside)
		return button
	}()

	// MARK: ...Initialization
	init(type: Type) {
		self.type = type
		super.init(frame: .zero)
		setup()
	}

	convenience init(type: Type, tapAction: @escaping TapAction) {
		self.init(type: type)
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
@objc private extension ButtonView
{
	func actionTap() {
		tapAction?()
	}
}

private extension ButtonView.`Type`
{
	func image(for state: UIButton.State) -> UIImage {
		switch (self, state) {
		case (.add, .normal):
			return #imageLiteral(resourceName: "icons8-map-pin-50")
		case (.add, .highlighted):
			return #imageLiteral(resourceName: "icons8-map-pin-50")
		case (.currentLocation, state) where state == .normal || state == .highlighted:
			return #imageLiteral(resourceName: "icons8-near-me-48")
		default:
			return UIImage()
		}
	}
}
