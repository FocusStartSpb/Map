//
//  SmartTargetMenu.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 22.12.2019.
//

import UIKit

typealias Action = (SmartTargetMenu) -> Void
typealias RadiusDidChange = (_ menu: SmartTargetMenu, _ value: Float) -> Void

final class SmartTargetMenu: UIView
{

	// MARK: ...Private properties
	private var radius: Float
	private var title: String?
	private let saveAction: Action
	private let cancelAction: Action
	private let radiusDidChange: RadiusDidChange

	private let blurredView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .light)
		let view = UIVisualEffectView(effect: blurEffect)
		return view
	}()

	private let vibrancyView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .light)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let view = UIVisualEffectView(effect: vibrancyEffect)
		return view
	}()

	private lazy var titleTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "type title..."
		textField.text = title
		return textField
	}()

	private lazy var radiusSlider: UISlider = {
		let slider = UISlider()
		slider.value = radius
		slider.addTarget(self, action: #selector(actionChangeRadius(_:)), for: .valueChanged)
		return slider
	}()

	private let saveButton: UIButton = {
		let button = UIButton()
		button.setTitleColor(.systemRed, for: .normal)
		button.setTitle("Save", for: .normal)
		button.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
		return button
	}()

	private let cancelButton: UIButton = {
		let button = UIButton()
		button.setTitleColor(.systemBlue, for: .normal)
		button.setTitle("Cancel", for: .normal)
		button.addTarget(self, action: #selector(actionCancel), for: .touchUpInside)
		return button
	}()

	// MARK: ...Initialization
	/// Основной инициализатор
	/// - Parameters:
	///   - title: textField с заголовком
	///   - radiusValue: Значение установленное на слайдере
	///   - saveAction: Блок кода выполняемый при нажатии на кнопку "Save"
	///   - cancelAction: Блок кода выполняемый при нажатии на кнопку "Cancel"
	///   - radiusChange: Блок кода выполняемый при изменении значения слайдера
	init(title: String? = nil,
		 radiusValue: Float = 0.5,
		 saveAction: @escaping Action,
		 cancelAction: @escaping Action,
		 radiusChange: @escaping RadiusDidChange) {
		self.radius = radiusValue
		self.title = title
		self.saveAction = saveAction
		self.cancelAction = cancelAction
		self.radiusDidChange = radiusChange

		super.init(frame: .zero)

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

		// Set layout margins
		layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		// Add subviews
		addSubview(blurredView)
		addSubview(radiusSlider)
		addSubview(saveButton)
		addSubview(cancelButton)

		// Set blurred effect view
		vibrancyView.contentView.addSubview(titleTextField)
		blurredView.contentView.addSubview(vibrancyView)

		setConstraints()
	}

	private func setConstraints() {
		titleTextField.translatesAutoresizingMaskIntoConstraints = false
		radiusSlider.translatesAutoresizingMaskIntoConstraints = false
		saveButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		blurredView.translatesAutoresizingMaskIntoConstraints = false
		vibrancyView.translatesAutoresizingMaskIntoConstraints = false

		// Set constraint for titleTextField
		titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left).isActive = true
		titleTextField.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top).isActive = true
		titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right).isActive = true

		// Set constraint for radiusSlider
		radiusSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left).isActive = true
		radiusSlider.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16).isActive = true
		radiusSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right).isActive = true

		// Set constraint for saveButton
		saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left).isActive = true
		saveButton.topAnchor.constraint(equalTo: radiusSlider.bottomAnchor, constant: 16).isActive = true
		saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutMargins.right).isActive = true

		// Set constraint for cancelButton
		cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right).isActive = true
		cancelButton.topAnchor.constraint(equalTo: radiusSlider.bottomAnchor, constant: 16).isActive = true

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
	private func hide() {
		UIProgressView.animate(withDuration: 0.3,
							   animations: { [weak self] in
								self?.alpha = 0
			},
							   completion: { [weak self] _ in
								self?.isHidden = true
		})
	}

	/// Сделать menu прозрачным
	/// - Parameters:
	///   - take: сделать прозрачным или нет
	///   - value: степень прозрачности от 0 до 1. Значение по умолчанию - 0.5
	func translucent(_ take: Bool, value: CGFloat = 0.5) {
		UIProgressView.animate(withDuration: 0.3) { [weak self] in
			self?.alpha = take ? value : 1
		}
	}
}

// MARK: - Actions
@objc extension SmartTargetMenu
{
	private func actionSave() {
		saveAction(self)
		hide()
	}

	private func actionCancel() {
		cancelAction(self)
		hide()
	}

	private func actionChangeRadius(_ sender: UISlider) {
		radius = sender.value
		radiusDidChange(self, radius)
	}
}
