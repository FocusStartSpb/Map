//
//  Date+Attendance+Address.swift
//  Map
//
//  Created by Anton on 17.01.2020.
//

import UIKit

protocol IUnedatableTargetsDetails
{
	func setDateOfCreationText(text: String)
	func setAddress(text: String?)
	func setInfoOfAttendance(numberOfVisits: String, totalStay: String, dateOfLastVisit: String)
	func hide()
	func show()
}

final class UneditableTargetsDetails: UIView
{
	private let dateOfCreationLabel = UILabel()
	private let attendanceView = SmartTargetAttendanceLabels()
	private let addressLabel = UILabel()
	private var heightAnchorForAddressLabel: NSLayoutConstraint?
	private var heightAnchorForAddressLabelEqualZero: NSLayoutConstraint?
	private var heightAnchorAttendanceView: NSLayoutConstraint?
	private var heighAttendanceViewEqualZero: NSLayoutConstraint?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		self.dateOfCreationLabel.translatesAutoresizingMaskIntoConstraints = false
		self.attendanceView.translatesAutoresizingMaskIntoConstraints = false
		self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(dateOfCreationLabel)
		self.addSubview(attendanceView)
		self.addSubview(addressLabel)
		NSLayoutConstraint.activate([
			//dateOfCreationLabel
			self.dateOfCreationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.dateOfCreationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.dateOfCreationLabel.topAnchor.constraint(equalTo: self.topAnchor),
			//attendanceView
			self.attendanceView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.attendanceView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.attendanceView.topAnchor.constraint(equalTo: self.dateOfCreationLabel.bottomAnchor),
			//addressLabel
			self.addressLabel.topAnchor.constraint(equalTo: self.attendanceView.bottomAnchor),
			self.addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.addressLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.addressLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
		self.heightAnchorForAddressLabel = self.addressLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
		self.heightAnchorForAddressLabelEqualZero = self.addressLabel.heightAnchor.constraint(equalToConstant: 0)
		self.heightAnchorForAddressLabel?.isActive = true
		self.heighAttendanceViewEqualZero =
			self.attendanceView.heightAnchor.constraint(equalToConstant: 0)
		self.addressLabel.numberOfLines = 0
		self.addressLabel.textAlignment = .center
		self.dateOfCreationLabel.textAlignment = .center
	}
}

extension UneditableTargetsDetails: IUnedatableTargetsDetails
{
	func setDateOfCreationText(text: String) {
		self.dateOfCreationLabel.text = text
	}

	func setAddress(text: String?) {
		self.addressLabel.text = text
	}

	func setInfoOfAttendance(numberOfVisits: String, totalStay: String, dateOfLastVisit: String) {
		if dateOfLastVisit.isEmpty {
			self.hideAttendanceView()
			return
		}
		self.attendanceView.setText(numberOfVisits: numberOfVisits,
									totalStay: totalStay,
									dateOfLastVisit: dateOfLastVisit)
	}

	func hide() {
		self.heightAnchorForAddressLabel?.isActive = false
		self.heightAnchorForAddressLabelEqualZero?.isActive = true
		self.attendanceView.hide()
	}

	func hideAttendanceView() {
		self.heighAttendanceViewEqualZero?.isActive = true
		self.attendanceView.hide()
	}

	func show() {
		self.heightAnchorForAddressLabelEqualZero?.isActive = false
		self.heightAnchorForAddressLabel?.isActive = true
		self.attendanceView.show()
	}
}
