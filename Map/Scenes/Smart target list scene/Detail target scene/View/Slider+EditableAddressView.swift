//
//  Slider+EditableAddressView.swift
//  Map
//
//  Created by Anton on 17.01.2020.
//

import UIKit
protocol ISliderAndEditableAddressView
{
	func hide()
	func show()

	var address: String { get set }
}

final class SliderAndEditableAddressView: UIView
{
	private let backgroundColorBelow13Ios = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	private let backgroundColorHigher13Ios = UIColor.systemGray
	private let radiusSlider = UISlider()
	private var sliderValueLabelWidth: NSLayoutConstraint?
	private var sliderValueLabelWidthEqualZero: NSLayoutConstraint?
	private let sliderValueLabel: UILabel = {
		let label = UILabel()
		label.text = "16166 m" //заглушка
		label.adjustsFontSizeToFitWidth = true
		label.contentMode = .center
		label.textAlignment = .left
		return label
	}()
	private let editableAddressLabel = UILabel()
	private var addressLabelHeightAnchorEqualZero: NSLayoutConstraint?
	private var addressLabelHeightAnchor: NSLayoutConstraint?
	private var addressLabelBottomAnchor: NSLayoutConstraint?
	private var sliderWidthAnchor: NSLayoutConstraint?
	private var sliderTrailingAnchor: NSLayoutConstraint?

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		self.radiusSlider.translatesAutoresizingMaskIntoConstraints = false
		self.editableAddressLabel.translatesAutoresizingMaskIntoConstraints = false
		self.sliderValueLabel.translatesAutoresizingMaskIntoConstraints = false
		self.sliderValueLabelWidthEqualZero = self.sliderValueLabel.widthAnchor.constraint(equalToConstant: 0)
		self.sliderValueLabelWidth = self.sliderValueLabel.widthAnchor.constraint(equalToConstant: 60)
		self.sliderValueLabelWidthEqualZero?.isActive = true
		NSLayoutConstraint.activate([
			//label for slider
			self.sliderValueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			self.sliderValueLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
			//slider
			self.radiusSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor,
													   constant: 16),
			self.radiusSlider.topAnchor.constraint(equalTo: self.topAnchor,
												   constant: 16),
			//editableAddressLabel
			self.editableAddressLabel.topAnchor.constraint(equalTo: self.radiusSlider.bottomAnchor,
														   constant: 8),
			self.editableAddressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
															   constant: 16),
			self.editableAddressLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
																constant: -16),
		])
		self.addressLabelHeightAnchorEqualZero = self.editableAddressLabel.heightAnchor.constraint(equalToConstant: 0)
		self.addressLabelHeightAnchor =
			self.editableAddressLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
		self.addressLabelHeightAnchorEqualZero?.isActive = true
		self.sliderWidthAnchor = self.radiusSlider.widthAnchor.constraint(equalToConstant: 0)
		self.sliderWidthAnchor?.isActive = true
		self.sliderTrailingAnchor =
			self.radiusSlider.trailingAnchor.constraint(equalTo: self.sliderValueLabel.leadingAnchor,
														constant: -8)
		self.addressLabelBottomAnchor =
			self.editableAddressLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
	}

	private func setupUI() {
		if #available(iOS 13.0, *) {
			self.backgroundColor = self.backgroundColorHigher13Ios
		}
		else {
			self.backgroundColor = self.backgroundColorBelow13Ios
		}
		self.layer.cornerRadius = 12
		self.alpha = 0.85
		self.addSubview(sliderValueLabel)
		self.addSubview(radiusSlider)
		self.addSubview(editableAddressLabel)
		setupConstraints()
		self.radiusSlider.alpha = 0
		self.editableAddressLabel.numberOfLines = 0
		self.editableAddressLabel.textAlignment = .center
	}
}

extension SliderAndEditableAddressView: ISliderAndEditableAddressView
{
	func hide() {
		self.addressLabelHeightAnchor?.isActive = false
		self.addressLabelHeightAnchorEqualZero?.isActive = true
		self.addressLabelBottomAnchor?.isActive = false
		self.editableAddressLabel.layoutIfNeeded()
		self.sliderTrailingAnchor?.isActive = false
		self.sliderWidthAnchor?.isActive = true
		self.sliderValueLabelWidth?.isActive = false
		self.sliderValueLabelWidthEqualZero?.isActive = true
		self.radiusSlider.alpha = 0
	}

	func show() {
		self.addressLabelHeightAnchorEqualZero?.isActive = false
		self.addressLabelBottomAnchor?.isActive = true
		self.addressLabelHeightAnchor?.isActive = true
		self.editableAddressLabel.layoutIfNeeded()
		self.sliderWidthAnchor?.isActive = false
		self.sliderValueLabelWidthEqualZero?.isActive = false
		self.sliderValueLabelWidth?.isActive = true
		self.sliderTrailingAnchor?.isActive = true
		self.radiusSlider.alpha = 1
	}

	var address: String {
		get { self.editableAddressLabel.text ?? "" }
		set {
			self.editableAddressLabel.setTextAnimation(newValue)
		}
	}
}
