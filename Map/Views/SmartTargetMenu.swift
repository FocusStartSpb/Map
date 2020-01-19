//
//  SmartTargetMenu.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 22.12.2019.
//

import UIKit

typealias SliderAction = (_ menu: SmartTargetMenu, _ value: Float) -> Void
typealias TextFieldAction = (_ menu: SmartTargetMenu, _ value: String) -> Void

final class SmartTargetMenu: UIView
{
	// MARK: ...Private properties
	private let sliderValueDidChange: SliderAction
	private let textFieldAction: TextFieldAction

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
		let blurEffect = UIBlurEffect(style: .prominent)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let view = UIVisualEffectView(effect: vibrancyEffect)
		return view
	}()

	private lazy var textField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Введите текст..."
		textField.textAlignment = .center
		textField.delegate = self
		textField.returnKeyType = .done
		textField.autocorrectionType = .no
		return textField
	}()

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

	private lazy var slider: UISlider = {
		let slider = UISlider()
		slider.minimumValueImage = #imageLiteral(resourceName: "radius-of-circle")
		slider.addTarget(self, action: #selector(actionSliderValueChanged), for: .valueChanged)
		return slider
	}()

	private var sliderLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .right
		return label
	}()

	private lazy var leftButton: UIButton = {
		let button = UIButton()
		setTitle(for: button, with: leftMenuAction)
		button.addTarget(self, action: #selector(actionLeftButton), for: .touchUpInside)
		return button
	}()

	private lazy var rightButton: UIButton = {
		let button = UIButton()
		setTitle(for: button, with: rightMenuAction)
		button.addTarget(self, action: #selector(actionRightButton), for: .touchUpInside)
		return button
	}()

	private let activityIndicator = UIActivityIndicatorView(style: Constants.activityIndicatorStyle)

	// MARK: ...Properties
	var leftMenuAction: MenuAction {
		didSet { setTitle(for: leftButton, with: leftMenuAction) }
	}
	var rightMenuAction: MenuAction {
		didSet { setTitle(for: rightButton, with: rightMenuAction) }
	}

	private(set) var text: String? {
		get { textField.text }
		set { textField.text = newValue }
	}

	var title: String? {
		get { titleLabel.text }
		set {
			titleLabel.text = newValue
			checkAddress()
		}
	}

	var sliderValuesRange: (min: Double, max: Double) {
		get { (Double(slider.minimumValue), Double(slider.maximumValue)) }
		set {
			slider.minimumValue = Float(newValue.min)
			slider.maximumValue = Float(newValue.max)
		}
	}

	var sliderValue: Float {
		get { slider.value }
		set {
			updateSliderLabel()
			slider.value = newValue
		}
	}

	var sliderFactor: Float = 1 {
		didSet { updateSliderLabel() }
	}
	var sliderValueMeasurementSymbol: String = "" {
		didSet { updateSliderLabel() }
	}

	var isEditable = true {
		didSet {
			slider.isEnabled = isEditable
			leftButton.isEnabled = isEditable
			rightButton.isEnabled = isEditable
		}
	}

	// MARK: ...Initialization
	/// Основной инициализатор
	/// - Parameters:
	///   - textField: textField с заголовком
	///   - sliderValue: Значение установленное на слайдере
	///   - sliderValuesRange: Диапазон значений слайдера
	///   - title: текст отображаемый в label`е
	///   - leftAction: Блок кода выполняемый при нажатии на кнопку кнопку слева
	///   - rightAction: Блок кода выполняемый при нажатии на кнопку кнопку справа
	///   - sliderAction: Блок кода выполняемый при изменении значения слайдера
	///   - textFieldAction: Блок кода выполняемый при изменении текста
	init(textField: String? = nil,
		 sliderValue: Double = 0,
		 sliderValuesRange: (min: Double, max: Double),
		 title: String? = nil,
		 leftAction: MenuAction,
		 rightAction: MenuAction,
		 sliderAction: @escaping SliderAction,
		 textFieldAction: @escaping TextFieldAction) {
		self.leftMenuAction = leftAction
		self.rightMenuAction = rightAction
		self.sliderValueDidChange = sliderAction
		self.textFieldAction = textFieldAction

		super.init(frame: .zero)

		self.text = textField
		self.title = title
		self.sliderValuesRange = sliderValuesRange
		self.sliderValue = Float(min(max(sliderValue, sliderValuesRange.min), sliderValuesRange.max))

		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ...Override methods
	@discardableResult override func becomeFirstResponder() -> Bool {
		textField.becomeFirstResponder()
	}

	// MARK: ...Private methods
	private func setup() {

		// Set corner radius
		layer.cornerRadius = 10
		clipsToBounds = true

		// Set layout margins
		layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		// Add subviews
		addSubview(blurredView)
		addSubview(slider)
		addSubview(textField)
		addSubview(sliderLabel)
		addSubview(leftButton)
		addSubview(rightButton)
		addSubview(activityIndicator)

		// Set blurred effect view
		vibrancyView.contentView.addSubview(titleLabel)
		blurredView.contentView.addSubview(vibrancyView)

		// Set constrains
		setConstraints()
	}

	private func checkAddress() {
		title == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
	}

	private func setConstraints() {
		textField.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		slider.translatesAutoresizingMaskIntoConstraints = false
		sliderLabel.translatesAutoresizingMaskIntoConstraints = false
		leftButton.translatesAutoresizingMaskIntoConstraints = false
		rightButton.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		blurredView.translatesAutoresizingMaskIntoConstraints = false
		vibrancyView.translatesAutoresizingMaskIntoConstraints = false

		// Set constraint for titleTextField
		textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		textField.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top).isActive = true

		// Set constraint for addressLabel
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left).isActive = true
		titleLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: layoutMargins.top).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right).isActive = true
		titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true

		// Set constraint for activityIndicator
		activityIndicator.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor).isActive = true
		activityIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true

		// Set constraint for radiusSlider
		slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left).isActive = true
		slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
		slider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2 / 3).isActive = true

		// Set constraint for radiusLabel
		sliderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
		sliderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right).isActive = true
		sliderLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3).isActive = true

		// Set constraint for saveButton
		leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left).isActive = true
		leftButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16).isActive = true
		leftButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutMargins.right).isActive = true

		// Set constraint for removeButton
		rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right).isActive = true
		rightButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16).isActive = true

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

	private func setTitle(for button: UIButton, with action: MenuAction) {
		button.setTitle(action.title, for: .normal)
		switch action.style {
		case .destructive:
			button.setTitleColor(.systemRed, for: .normal)
		case .cancel:
			button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
			fallthrough
		case .default:
			button.setTitleColor(.systemBlue, for: .normal)
		@unknown default:
			fatalError("Cannot finde case")
		}
	}

	private func updateSliderLabel() {
		sliderLabel.text =
			"\(Int(sliderValue * sliderFactor))" +
			((sliderValueMeasurementSymbol.isEmpty == false) ? " \(sliderValueMeasurementSymbol)" : "")
	}

	// MARK: ...Methods
	/// Сделать menu прозрачным
	/// - Parameters:
	///   - take: сделать прозрачным или нет
	///   - value: степень прозрачности от 0 до 1. Значение по умолчанию - 0.5
	func translucent(_ take: Bool, value: CGFloat = 0.5) {
		UIView.animate(withDuration: 0.3) { self.alpha = take ? value : 1 }
	}

	func hide(_ completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: 0.3, animations: { self.alpha = 0 }, completion: { _ in
			self.isHidden = true
			completion?()
		})
	}

	func show(_ completion: (() -> Void)? = nil) {
		self.isHidden = false
		UIView.animate(withDuration: 0.3) { self.alpha = 1 }
	}

	func highlightTextField(_ flag: Bool) {
		let placeholderColor: UIColor
		if flag {
			placeholderColor = .systemRed
		}
		else if #available(iOS 13.0, *) {
			placeholderColor = .placeholderText
		}
		else {
			placeholderColor = .gray
		}
		textField.attributedPlaceholder =
			NSAttributedString(string: textField.placeholder ?? "",
							   attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
	}
}

// MARK: - Actions
@objc private extension SmartTargetMenu
{
	func actionLeftButton() {
		leftMenuAction.handler?(leftMenuAction)
	}

	func actionRightButton() {
		rightMenuAction.handler?(rightMenuAction)
	}

	func actionSliderValueChanged(_ sender: UISlider) {
		sliderValue = sender.value
		sliderValueDidChange(self, sliderValue)
	}
}

// MARK: - Text field delegate
extension SmartTargetMenu: UITextFieldDelegate
{
	func textField(_ textField: UITextField,
				   shouldChangeCharactersIn range: NSRange,
				   replacementString string: String) -> Bool {
		guard
			isEditable,
			let text = textField.text,
			let range = Range<String.Index>(range, in: text) else {
				return false
		}
		let newString = textField.text?.replacingCharacters(in: range, with: string)

		let didEdit = newString?.count ?? 0 <= Constants.maxLenghtOfTitle
		if let newString = newString, didEdit {
			textFieldAction(self, newString)
		}
		return didEdit
	}

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		isEditable
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard isEditable else { return false }
		textField.resignFirstResponder()
		return true
	}
}
