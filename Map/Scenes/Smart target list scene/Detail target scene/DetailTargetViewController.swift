//
//  DetailSmartTargetScene.swift
//  Map
//
//  Created by Антон on 29.12.2019.
//

import MapKit

final class DetailTargetViewController: UIViewController
{
	// MARK: - Private properties
	private enum ScreenProperties
	{
		static let width = UIScreen.main.bounds.width
		static let height = UIScreen.main.bounds.height
	}

	private enum FontForDetailScreen
	{
		static let timeOfCreationFont = UIFont.systemFont(ofSize: 20, weight: .light)
		static let titleLabelDescriptionFont = UIFont.systemFont(ofSize: 17)
		static let titleLabelFont = UIFont.systemFont(ofSize: 25, weight: .semibold)
		static let addressLabelFont = UIFont.systemFont(ofSize: 25, weight: .regular)
	}

	private let presenter: IDetailTargetPresenter
	private let router: IDetailTargetRouter
	private let smartTargetEditable: Bool
	private var userInterfaceIsDark: Bool {
		if #available(iOS 12.0, *) {
			return self.traitCollection.userInterfaceStyle == .dark ? true : false
		}
		return false
	}

	private let dismissView = DismissView()
	private let mapView = MKMapView()
	private let scrollView = UIScrollView()
	private let titleDescriptionLabel = UILabel()
	private let titleTextView = UITextView()
	private let dateOfCreationDescriptionLabel = UILabel()
	private let dateOfCreationLabel = UILabel()
	private let addresDescriptionLabel = UILabel()
	private let addressLabel = UILabel()

	init(presenter: IDetailTargetPresenter,
		 router: IDetailTargetRouter,
		 smartTargetEditable: Bool) {
		self.presenter = presenter
		self.router = router
		self.smartTargetEditable = smartTargetEditable
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lyficycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.isTranslucent = false
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.navigationBar.isTranslucent = true
	}

	// MARK: - Private methods
	private func setup() {
		presenter.getTarget()
		self.navigationItem.largeTitleDisplayMode = .never
		self.navigationItem.title = "Edit"
		setupUI()
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
															  action: #selector(hideKeyboard)))
	}

	// MARK: - Setup UI
	private func setupUI() {
		setupDismissView()
		setupScrollView()
		setupTitleDescriptionLabel()
		setupTitleTextView()
		setupDateOfCreationLabel()
		setupAddresLabel()
		setupMapView()
		checkUserInterfaceStyle()
	}
	// MARK: - dismissView
	private func setupDismissView() {
		guard self.smartTargetEditable == false else { return }
		self.view.addSubview(dismissView)
		self.dismissView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.dismissView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.dismissView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.dismissView.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
			self.dismissView.heightAnchor.constraint(equalToConstant: 40),
		])
		self.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self,
																	 action: #selector(dismissDetail)))
	}
	// MARK: - scrollView
	private func setupScrollView() {
		self.view.addSubview(scrollView)
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		switch self.smartTargetEditable {
		case true:
			self.scrollView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
		default:
			self.scrollView.topAnchor.constraint(equalTo: self.dismissView.bottomAnchor).isActive = true
		}
		NSLayoutConstraint.activate([
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
		])
		self.scrollView.contentMode = .center
	}
	// MARK: - titleDescriptionLabel
	private func setupTitleDescriptionLabel() {
		self.titleDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.addSubview(titleDescriptionLabel)
		NSLayoutConstraint.activate([
			self.titleDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.titleDescriptionLabel.topAnchor.constraint(equalTo: self.scrollView.topAnchor,
															constant: 10),
			self.titleDescriptionLabel.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
			self.titleDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
		])
		self.titleDescriptionLabel.text = "Title"
		self.titleDescriptionLabel.font = UIFont.systemFont(ofSize: 20)
		self.titleDescriptionLabel.textAlignment = .center
	}
	// MARK: - titleTextView
	private func setupTitleTextView() {
		self.scrollView.addSubview(titleTextView)
		titleTextView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.titleTextView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.titleTextView.topAnchor.constraint(equalTo: self.titleDescriptionLabel.bottomAnchor),
			self.titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			self.titleTextView.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
		])
		self.titleTextView.text = presenter.getTitleText()
		self.titleTextView.isScrollEnabled = false
		self.titleTextView.isUserInteractionEnabled = (self.smartTargetEditable == true)
		self.titleTextView.font = FontForDetailScreen.titleLabelFont
		self.titleTextView.backgroundColor = .clear
		self.titleTextView.textAlignment = .center
		self.titleTextView.layer.cornerRadius = 10
		guard self.smartTargetEditable else { return }
		self.titleTextView.layer.borderWidth = 0.1
		self.titleTextView.backgroundColor = self.userInterfaceIsDark ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 0.896545194, green: 0.896545194, blue: 0.896545194, alpha: 1)
		self.titleTextView.returnKeyType = .done
		self.titleTextView.delegate = self
	}
	// MARK: - dateOfCreationLabel
	private func setupDateOfCreationLabel() {
		self.scrollView.addSubview(dateOfCreationLabel)
		self.dateOfCreationLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.dateOfCreationLabel.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.dateOfCreationLabel.topAnchor.constraint(equalTo: self.titleTextView.bottomAnchor,
														  constant: 20),
			self.dateOfCreationLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			self.dateOfCreationLabel.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
		])
		self.dateOfCreationLabel.text = presenter.getDateOfCreation()
		self.dateOfCreationLabel.numberOfLines = 2
		self.dateOfCreationLabel.font = FontForDetailScreen.timeOfCreationFont
		self.dateOfCreationLabel.textAlignment = .center
	}
	// MARK: - addressLabel
	private func setupAddresLabel() {
		self.scrollView.addSubview(addressLabel)
		self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.addressLabel.topAnchor.constraint(equalTo: self.dateOfCreationLabel.bottomAnchor,
												   constant: 20),
			self.addressLabel.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.addressLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			self.addressLabel.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
		])
		self.addressLabel.numberOfLines = 0
		self.addressLabel.text = presenter.getAddressText()
		self.addressLabel.font = FontForDetailScreen.addressLabelFont
		self.addressLabel.textAlignment = .center
	}
	// MARK: - mapView
	private func setupMapView() {
		self.scrollView.addSubview(mapView)
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		let topAnchor = self.mapView.topAnchor.constraint(equalTo: self.addressLabel.bottomAnchor,
														  constant: 20)
		topAnchor.priority = .required
		NSLayoutConstraint.activate([
			topAnchor,
			self.mapView.heightAnchor.constraint(equalToConstant: ScreenProperties.height / 2),
			self.mapView.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
			self.mapView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor,
												 constant: -20),
			self.mapView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.mapView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
		])
		self.mapView.isUserInteractionEnabled = self.smartTargetEditable
	}

	private func checkUserInterfaceStyle() {
		if self.userInterfaceIsDark == true {
			self.view.backgroundColor = #colorLiteral(red: 0.2204069229, green: 0.2313892178, blue: 0.253805164, alpha: 1)
			self.dismissView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
			self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
		}
		else {
			self.view.backgroundColor = #colorLiteral(red: 0.9871620841, green: 0.9871620841, blue: 0.9871620841, alpha: 1)
			self.dismissView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
			self.navigationController?.navigationBar.barTintColor = .white
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		checkUserInterfaceStyle()
	}

	// MARK: - hideKeyboard
	@objc func hideKeyboard() {
		self.view.endEditing(true)
	}

	// MARK: - Dismiss function
	@objc func dismissDetail() {
		self.smartTargetEditable ? self.router.popDetail() : self.router.dismissDetail()
	}
}
// MARK: - UITextViewDelegate
extension DetailTargetViewController: UITextViewDelegate
{
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}
