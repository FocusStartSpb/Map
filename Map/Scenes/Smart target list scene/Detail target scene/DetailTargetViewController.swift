//
//  DetailSmartTargetScene.swift
//  Map
//
//  Created by Антон on 29.12.2019.
//
// swiftlint:disable file_length
import MapKit

final class DetailTargetViewController: UIViewController
{
	// MARK: - Private properties
	private enum ScreenProperties
	{
		static let width = UIScreen.main.bounds.width
		static let height = UIScreen.main.bounds.height
	}

	private enum ButtonTitles
	{
		static let editButtonTitleDefault = "Edit (only title and target location)"
		static let editButtonTitleEditableMode = "Save changes"
		static let cancelButtonTitle = "Cancel"
	}

	private enum FontForDetailScreen
	{
		static let timeOfCreationFont = UIFont.systemFont(ofSize: 20, weight: .light)
		static let titleLabelDescriptionFont = UIFont.systemFont(ofSize: 17)
		static let titleLabelFont = UIFont.systemFont(ofSize: 25, weight: .semibold)
		static let addressLabelFont = UIFont.systemFont(ofSize: 25, weight: .regular)
	}

	var presenter: IDetailTargetPresenter
	private let router: IDetailTargetRouter
	private var smartTargetEditable: Bool {
		didSet {
			if smartTargetEditable {
				self.navigationController?.setNavigationBarHidden(true, animated: true)
				UIView.animate(withDuration: 0.2, animations: {
					self.editButtonLeadingAnchorToScrollView?.isActive = false
					self.editButtonLeadingAnchorToCancelButton?.isActive = true
					self.cancelButtonWidthAnchorEqualZero?.isActive = false
					self.cancelButtonWidthAnchorIfEditModeEnabled?.isActive = true
					self.cancelButton.layoutIfNeeded()
					self.editButton.layoutIfNeeded()
					self.editButton.setTitle(ButtonTitles.editButtonTitleEditableMode, for: .normal)
					self.titleTextViewEditable()
					self.mapViewEditable()
				})
			}
			else {
				self.navigationController?.setNavigationBarHidden(false, animated: true)
				UIView.animate(withDuration: 0.2, animations: {
					self.titleTextView.text = self.presenter.getTitleText()
					self.editButton.setTitle(ButtonTitles.editButtonTitleDefault, for: .normal)
					self.titleTextViewNotEditable()
					self.mapViewNotEditable()
					self.cancelButtonWidthAnchorIfEditModeEnabled?.isActive = false
					self.cancelButtonWidthAnchorEqualZero?.isActive = true
					self.editButtonLeadingAnchorToCancelButton?.isActive = false
					self.editButtonLeadingAnchorToScrollView?.isActive = true
					self.mapViewNotEditable()
					self.titleTextViewNotEditable()
					self.cancelButton.layoutIfNeeded()
					self.editButton.layoutIfNeeded()
				})
			}
		}
	}
	private var userInterfaceIsDark: Bool {
		if #available(iOS 12.0, *) {
			return self.traitCollection.userInterfaceStyle == .dark ? true : false
		}
		return false
	}

	private(set) lazy var mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.delegate = self
		mapView.showsCompass = false
		return mapView
	}()

	private let scrollView = UIScrollView()
	private let titleDescriptionLabel = UILabel()
	private let titleTextView = UITextView()
	private let dateOfCreationDescriptionLabel = UILabel()
	private let dateOfCreationLabel = UILabel()
	private let addresDescriptionLabel = UILabel()
	private let addressLabel = UILabel()
	private let editButton = ButtonForDetailScreen(backgroundColor: .systemBlue, frame: .zero)
	private var editButtonWidthAnchor: NSLayoutConstraint?
	private var editButtonLeadingAnchorToScrollView: NSLayoutConstraint?
	private var editButtonLeadingAnchorToCancelButton: NSLayoutConstraint?
	private let cancelButton = ButtonForDetailScreen(backgroundColor: .systemRed, frame: .zero)
	private var cancelButtonWidthAnchorEqualZero: NSLayoutConstraint?
	private var cancelButtonWidthAnchorIfEditModeEnabled: NSLayoutConstraint?

	let impactFeedbackGenerator: UIImpactFeedbackGenerator = {
		if #available(iOS 13.0, *) {
			return UIImpactFeedbackGenerator(style: .soft)
		}
		else {
			return UIImpactFeedbackGenerator(style: .light)
		}
	}()

	private lazy var showPinButtonView = ButtonView(type: .add, tapAction: actionShowPin)

	private let activityIndicator: UIActivityIndicatorView = {
		let style: UIActivityIndicatorView.Style
		if #available(iOS 13.0, *) {
			style = .medium
		}
		else {
			style = .gray
		}
		let indicator = UIActivityIndicatorView(style: style)
		return indicator
	}()

	var addressText: String? {
		get { addressLabel.text }
		set {
			addressLabel.text = newValue
			newValue == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
		}
	}

	init(presenter: IDetailTargetPresenter,
		 router: IDetailTargetRouter) {
		self.presenter = presenter
		self.router = router
		self.smartTargetEditable = false
		super.init(nibName: nil, bundle: nil)
		self.hidesBottomBarWhenPushed = true
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

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}

	// MARK: - Private methods
	private func setup() {
		self.navigationItem.largeTitleDisplayMode = .never
		setupUI()
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
															  action: #selector(hideKeyboard)))
	}

	// MARK: - Setup UI
	private func setupUI() {
		setupScrollView()
		setupTitleDescriptionLabel()
		setupTitleTextView()
		setupDateOfCreationLabel()
		setupAddresLabel()
		setupMapView()
		setupEditButton()
		setupCancelButton()
		checkUserInterfaceStyle()
		setupShowPinButtonView()
		setupActivityIndicator()
		setupAnnotation()
		setupOverlay()
		setSmartTargetRegion(coordinate: presenter.editCoordinate, animated: false)
	}

	@objc private func editButtonAction() {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		if self.editButton.currentTitle == ButtonTitles.editButtonTitleEditableMode {
			guard let smartTargetVC = self.navigationController?.viewControllers.first as? SmartTargetListViewController
				else { return }
			self.router.popDetail(to: smartTargetVC,
								  smartTarget: presenter.saveChanges(title: self.titleTextView.text,
																	 address: addressText))
		}
		self.smartTargetEditable = true
	}

	@objc private func cancelButtonAction() {
		if let annotation = mapView
			.annotations
			.first(where: { $0 is SmartTargetAnnotation }) as? SmartTargetAnnotation {
			self.mapView.removeAnnotation(annotation)
			self.mapView.removeOverlays(self.mapView.overlays)
			self.presenter.setupInitialData()
			self.setupAnnotation()
			self.setupOverlay()
			self.setSmartTargetRegion(coordinate: presenter.editCoordinate, animated: true)
		}
		self.smartTargetEditable = false
	}

	private func checkUserInterfaceStyle() {
		if self.userInterfaceIsDark == true {
			self.view.backgroundColor = #colorLiteral(red: 0.2204069229, green: 0.2313892178, blue: 0.253805164, alpha: 1)
			self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
		}
		else {
			self.view.backgroundColor = #colorLiteral(red: 0.9871620841, green: 0.9871620841, blue: 0.9871620841, alpha: 1)
			self.navigationController?.navigationBar.barTintColor = .white
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		checkUserInterfaceStyle()
	}

	// MARK: - hideKeyboard
	@objc private func hideKeyboard() {
		self.view.endEditing(true)
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

	func textViewDidBeginEditing(_ textView: UITextView) {
		self.mapView.isUserInteractionEnabled = false
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		self.mapView.isUserInteractionEnabled = true
	}
}

extension DetailTargetViewController
{
	// MARK: - scrollView
	private func setupScrollView() {
		self.view.addSubview(scrollView)
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
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
		self.titleDescriptionLabel.font = UIFont.systemFont(ofSize: 20)
		self.titleDescriptionLabel.textAlignment = .center
	}
	// MARK: - titleTextView
	private func titleTextViewEditable() {
		self.titleTextView.isUserInteractionEnabled = true
		UIView.animate(withDuration: 0.3, animations: {
			self.titleTextView.backgroundColor = self.userInterfaceIsDark ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 0.896545194, green: 0.896545194, blue: 0.896545194, alpha: 1)
			self.titleTextView.returnKeyType = .done
			self.titleTextView.delegate = self
		})
	}

	private func titleTextViewNotEditable() {
		self.titleTextView.isUserInteractionEnabled = false
		UIView.animate(withDuration: 0.2, animations: {
			self.titleTextView.font = FontForDetailScreen.titleLabelFont
			self.titleTextView.backgroundColor = .clear
		})
	}

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
		self.titleTextView.textAlignment = .center
		self.titleTextView.layer.cornerRadius = 10
		titleTextViewNotEditable()
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
		self.addressLabel.font = FontForDetailScreen.addressLabelFont
		self.addressLabel.textAlignment = .center
		presenter.getAddressText {
			self.addressLabel.text = $0
			self.activityIndicator.stopAnimating()
		}
	}
	// MARK: - mapView
	private func mapViewEditable() {
		UIView.animate(withDuration: 0.2, animations: {
			self.mapView.layer.cornerRadius = 30
		})
		self.mapView.isUserInteractionEnabled = true
		//do something
	}

	private func mapViewNotEditable() {
		UIView.animate(withDuration: 0.2, animations: {
			self.mapView.layer.cornerRadius = 0
		})
		self.mapView.isUserInteractionEnabled = false
		//do something
	}

	private func setupMapView() {
		self.scrollView.addSubview(mapView)
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		let topAnchor = self.mapView.topAnchor.constraint(equalTo: self.addressLabel.bottomAnchor,
														  constant: 20)
		topAnchor.priority = .required
		NSLayoutConstraint.activate([
			topAnchor,
			self.mapView.heightAnchor.constraint(equalToConstant: ScreenProperties.height / 2),
			self.mapView.widthAnchor.constraint(equalToConstant: ScreenProperties.width - 10),
			self.mapView.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),
		])
		self.mapViewNotEditable()
	}
	// MARK: ...EditButton
	private func setupEditButton() {
		self.editButton.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.addSubview(editButton)
		self.editButtonLeadingAnchorToCancelButton = self.editButton
			.leadingAnchor.constraint(equalTo: self.cancelButton.trailingAnchor, constant: 15)
		self.editButtonLeadingAnchorToScrollView = self.editButton
			.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor)
		self.editButtonLeadingAnchorToScrollView?.isActive = true
		NSLayoutConstraint.activate([
			self.editButton.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: 10),
			self.editButton.heightAnchor.constraint(equalToConstant: 50),
			//			self.editButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 130),
			self.editButton.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor),
			self.editButton.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor,
													constant: -15),
		])
		self.editButton.setTitle(ButtonTitles.editButtonTitleDefault, for: .normal)
		self.editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
	}
	// MARK: ...CancelButton
	private func setupCancelButton() {
		self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.addSubview(cancelButton)
		self.cancelButtonWidthAnchorEqualZero = self.cancelButton.widthAnchor.constraint(equalToConstant: 0)
		self.cancelButtonWidthAnchorEqualZero?.isActive = true
		self.cancelButtonWidthAnchorIfEditModeEnabled = self.cancelButton
			.widthAnchor.constraint(equalTo: self.editButton.widthAnchor, multiplier: 2 / 3)
		NSLayoutConstraint.activate([
			self.cancelButton.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: 10),
			self.cancelButton.heightAnchor.constraint(equalToConstant: 50),
			self.cancelButton.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor,
													   constant: 15),
			self.cancelButton.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor,
													  constant: -15),
		])
		self.cancelButton.setTitle(ButtonTitles.cancelButtonTitle, for: .normal)
		self.cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
	}

	private func setupShowPinButtonView() {
		self.showPinButtonView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.addSubview(showPinButtonView)
		NSLayoutConstraint.activate([
			self.showPinButtonView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -8),
			self.showPinButtonView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8),
			self.showPinButtonView.heightAnchor.constraint(equalToConstant: 40),
			self.showPinButtonView.widthAnchor.constraint(equalToConstant: 40),
		])
	}

	private func setupActivityIndicator() {
		self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.addSubview(activityIndicator)
		NSLayoutConstraint.activate([
			self.activityIndicator.centerXAnchor.constraint(equalTo: addressLabel.centerXAnchor),
			self.activityIndicator.centerYAnchor.constraint(equalTo: addressLabel.centerYAnchor),
		])
	}
}

// MARK: - Actions
private extension DetailTargetViewController
{
	func actionShowPin() {
		setSmartTargetRegion(coordinate: presenter.editCoordinate, animated: true)
	}
}
