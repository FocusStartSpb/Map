//
//  ButtonsBar.swift
//  Map
//
//  Created by Anton on 18.01.2020.
//

import UIKit

protocol IButtonBar
{
	func addActionForCancelButton(action: @escaping TapAction)
	func addActionForEditButton(action: @escaping TapAction)
}

final class ButtonsBar: UIView
{
	private let titleForEditButtonNoEditableMode = "Редактировать"
	private let titleForEditButtonEditableMode = "Сохранить"
	private let titleForCancelButton = "Отменить"
	private let editOrSaveButton = ButtonForDetailScreen(backgroundColor: .systemBlue, frame: .zero)
	private var editOrSaveButtonLeadingToView: NSLayoutConstraint?
	private var editOrSaveButtonLeadingToCancelButton: NSLayoutConstraint?
	private let cancelButton = ButtonForDetailScreen(backgroundColor: .systemRed, frame: .zero)
	private var cancelButtonWidthAnchor: NSLayoutConstraint?
	private var cancelButtonWidthAnchorEqualZero: NSLayoutConstraint?
	private var cancelButtonTap: TapAction?
	private var editOrSaveButtonTap: TapAction?

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupBlurEffect()
		setupEditButton()
		setupCancelButton()
		setupConstraints()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupBlurEffect() {
		let blurEffect = UIBlurEffect(style: .prominent)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		self.addSubview(blurEffectView)
		blurEffectView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			blurEffectView.topAnchor.constraint(equalTo: self.topAnchor),
			blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
	}
	private func setupEditButton() {
		self.editOrSaveButton.setTitle(titleForEditButtonNoEditableMode, for: .normal)
		self.editOrSaveButton.addTarget(self, action: #selector(self.editButtonAction), for: .touchUpInside)
	}
	private func setupCancelButton() {
		self.cancelButton.setTitle(titleForCancelButton, for: .normal)
		self.cancelButton.addTarget(self, action: #selector(self.cancelButtonAction), for: .touchUpInside)
	}

	private func setupConstraints() {
		self.addSubview(self.editOrSaveButton)
		self.addSubview(self.cancelButton)
		self.editOrSaveButton.translatesAutoresizingMaskIntoConstraints = false
		self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
		self.cancelButtonWidthAnchor =
			self.cancelButton.widthAnchor.constraint(equalTo: self.editOrSaveButton.widthAnchor, multiplier: 2 / 3)
		self.cancelButtonWidthAnchorEqualZero = self.cancelButton.widthAnchor.constraint(equalToConstant: 0)
		self.cancelButtonWidthAnchorEqualZero?.isActive = true
		self.editOrSaveButtonLeadingToView =
			self.editOrSaveButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
		self.editOrSaveButtonLeadingToCancelButton =
			self.editOrSaveButton.leadingAnchor.constraint(equalTo: self.cancelButton.trailingAnchor,
		constant: 16)
		self.editOrSaveButtonLeadingToView?.isActive = true
		NSLayoutConstraint.activate([
			self.cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			self.cancelButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
			self.cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),

			self.editOrSaveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			self.editOrSaveButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
			self.editOrSaveButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
		])
	}
}
@objc private extension ButtonsBar
{
	private func cancelButtonAction() {
		self.cancelButtonTap?()
		UIView.animate(withDuration: 0.3, animations: {
			self.cancelButtonWidthAnchor?.isActive = false
			self.cancelButtonWidthAnchorEqualZero?.isActive = true
			self.editOrSaveButtonLeadingToCancelButton?.isActive = false
			self.editOrSaveButtonLeadingToView?.isActive = true
			self.editOrSaveButton.setTitle(self.titleForEditButtonNoEditableMode, for: .normal)
			self.layoutIfNeeded()
		})
	}

	private func editButtonAction() {
		self.editOrSaveButtonTap?()
		UIView.animate(withDuration: 0.3, animations: {
			if self.editOrSaveButton.titleLabel?.text == self.titleForEditButtonNoEditableMode {
				self.editOrSaveButton.setTitle(self.titleForEditButtonEditableMode, for: .normal)
				self.cancelButtonWidthAnchorEqualZero?.isActive = false
				self.cancelButtonWidthAnchor?.isActive = true
				self.editOrSaveButtonLeadingToView?.isActive = false
				self.editOrSaveButtonLeadingToCancelButton?.isActive = true
				self.layoutIfNeeded()
			}
			else {
				return
			}
		})
	}
}

extension ButtonsBar: IButtonBar
{
	func addActionForCancelButton(action: @escaping TapAction) {
		self.cancelButtonTap = action
	}

	func addActionForEditButton(action: @escaping TapAction) {
		self.editOrSaveButtonTap = action
	}
}
