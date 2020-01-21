//
//  SmarTargetAttendanceLabels.swift
//  Map
//
//  Created by Anton on 17.01.2020.
//

import UIKit

protocol ISmartTargetAttendanceLabels
{
	func setText(numberOfVisits: String, totalStay: String, dateOfLastVisit: String)
	func hide()
	func show()
}

final class SmartTargetAttendanceLabels: UIView
{
	private enum StaticTextForLabels
	{
		static let showDetails = "Показать информацию о посещениях"
		static let hideDetails = "Скрыть информацию о посещениях"
		static let totalNumbersOfVisitsText = "Общее количество посещений: "
		static let totalStayText = "Общее время прибывания: "
		static let dateOfLastVisitText = "Дата последнего посещения: "
		static let newLineSymbol = "\n"
	}

	private let showOrHideDetailsView = UIView()
	private let showOrHideDetailsViewLabel = UILabel()

	private let verticalStack = UIStackView()
	private var verticalStackHeightConstraint: NSLayoutConstraint?
	private var verticalStackHeightConstraintEqualZero: NSLayoutConstraint?
	private let totalNumbersOfVisitsLabel = UILabel()
	private let totalStayLabel = UILabel()
	private let dateOfLastVisitLabel = UILabel()
	private let chevronImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = #imageLiteral(resourceName: "down-chevron")
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		return imageView
	}()
	private var chevronImageViewCenterYAnchor: NSLayoutConstraint?
	private var chevronImageViewHeightAnchor: NSLayoutConstraint?
	private var verticalStackIsHidden = false {
		didSet {
			if verticalStackIsHidden {
				self.verticalStackShowWithAnimation()
			}
			else {
				verticalStackHideWithAnimation()
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupShowOrHideDetailView()
		self.setupVerticalStack()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func labelsSettings(label: UILabel) {
		label.textAlignment = .center
		label.font = Constants.Fonts.ForDetailScreen.attendanceLabels
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.01
	}

	private func setupShowOrHideDetailView() {
		self.addSubview(showOrHideDetailsView)
		self.showOrHideDetailsView.addSubview(chevronImageView)
		self.showOrHideDetailsView.addSubview(self.showOrHideDetailsViewLabel)
		self.showOrHideDetailsViewLabel.text = StaticTextForLabels.showDetails
		self.labelsSettings(label: showOrHideDetailsViewLabel)
		self.showOrHideDetailsView.translatesAutoresizingMaskIntoConstraints = false
		self.showOrHideDetailsViewLabel.translatesAutoresizingMaskIntoConstraints = false
		self.chevronImageView.translatesAutoresizingMaskIntoConstraints = false
		self.chevronImageViewCenterYAnchor =
			self.chevronImageView.centerYAnchor.constraint(equalTo: self.showOrHideDetailsView.centerYAnchor)
		self.chevronImageViewHeightAnchor = self.chevronImageView.heightAnchor.constraint(equalToConstant: 0)
		self.chevronImageViewCenterYAnchor?.isActive = true
		NSLayoutConstraint.activate([
			self.showOrHideDetailsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.showOrHideDetailsView.topAnchor.constraint(equalTo: self.topAnchor),
			self.showOrHideDetailsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.showOrHideDetailsViewLabel.leadingAnchor.constraint(equalTo: self.showOrHideDetailsView.leadingAnchor),
			self.showOrHideDetailsViewLabel.topAnchor.constraint(equalTo: self.self.showOrHideDetailsView.topAnchor),
			self.showOrHideDetailsViewLabel.bottomAnchor.constraint(equalTo: self.showOrHideDetailsView.bottomAnchor),
			self.chevronImageView.leadingAnchor.constraint(equalTo: self.showOrHideDetailsViewLabel.trailingAnchor,
														   constant: 15),
			self.chevronImageView.trailingAnchor.constraint(equalTo: self.showOrHideDetailsView.trailingAnchor),
			self.chevronImageView.widthAnchor.constraint(equalToConstant: 30),
		])
		self.showOrHideDetailsView.addGestureRecognizer(UITapGestureRecognizer(target: self,
																			   action: #selector(showOrHideStackView)))
	}

	private func setupVerticalStack() {
		self.addSubview(verticalStack)
		let labelsArray = [totalNumbersOfVisitsLabel, totalStayLabel, dateOfLastVisitLabel]
		for label in labelsArray {
			labelsSettings(label: label)
			verticalStack.addArrangedSubview(label)
		}
		self.verticalStack.alignment = .center
		self.verticalStack.axis = .vertical
		self.verticalStack.distribution = .fillEqually
		self.verticalStack.translatesAutoresizingMaskIntoConstraints = false
		self.verticalStackHeightConstraintEqualZero = self.verticalStack.heightAnchor.constraint(equalToConstant: 0)
		self.verticalStackHeightConstraint = self.verticalStack.heightAnchor.constraint(equalToConstant: 150)
		self.verticalStackHeightConstraintEqualZero?.isActive = true
		NSLayoutConstraint.activate([
			self.verticalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.verticalStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.verticalStack.topAnchor.constraint(equalTo: self.showOrHideDetailsView.bottomAnchor),
			self.verticalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
		self.totalNumbersOfVisitsLabel.text = StaticTextForLabels.totalNumbersOfVisitsText
		self.totalStayLabel.text = StaticTextForLabels.totalStayText
		self.dateOfLastVisitLabel.text = StaticTextForLabels.dateOfLastVisitText
	}

	private func verticalStackShowWithAnimation() {
		UIView.animate(withDuration: 0.3, animations: {
			self.verticalStackHeightConstraintEqualZero?.isActive = false
			self.verticalStackHeightConstraint?.isActive = true
			self.showOrHideDetailsViewLabel.setTextAnimation(StaticTextForLabels.hideDetails)
			self.superview?.superview?.layoutIfNeeded()
			self.chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
		})
	}

	private func verticalStackHideWithAnimation() {
		UIView.animate(withDuration: 0.3, animations: {
			self.verticalStackHeightConstraint?.isActive = false
			self.verticalStackHeightConstraintEqualZero?.isActive = true
			self.showOrHideDetailsViewLabel.setTextAnimation(StaticTextForLabels.showDetails)
			self.superview?.superview?.layoutIfNeeded()
			self.chevronImageView.transform = CGAffineTransform(rotationAngle: 0)
		})
	}

	@objc private func showOrHideStackView() {
		self.verticalStackIsHidden.toggle()
	}
}

extension SmartTargetAttendanceLabels: ISmartTargetAttendanceLabels
{
	func setText(numberOfVisits: String, totalStay: String, dateOfLastVisit: String) {
		self.totalNumbersOfVisitsLabel.text = StaticTextForLabels.totalNumbersOfVisitsText +
			StaticTextForLabels.newLineSymbol + numberOfVisits
		self.totalStayLabel.text = StaticTextForLabels.totalStayText +
		StaticTextForLabels.newLineSymbol + totalStay
		self.dateOfLastVisitLabel.text = StaticTextForLabels.dateOfLastVisitText +
			StaticTextForLabels.newLineSymbol + dateOfLastVisit
	}

	func hide() {
		self.verticalStackIsHidden = false
		self.chevronImageViewCenterYAnchor?.isActive = false
		self.chevronImageViewHeightAnchor?.isActive = true
	}

	func show() {
		guard self.dateOfLastVisitLabel.text != StaticTextForLabels.dateOfLastVisitText else { return }
		self.chevronImageViewHeightAnchor?.isActive = false
		self.chevronImageViewCenterYAnchor?.isActive = true
	}
}
