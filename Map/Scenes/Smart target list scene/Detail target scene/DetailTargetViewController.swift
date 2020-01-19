//
//  DetailSmartTargetScene.swift
//  Map
//
//  Created by Антон on 29.12.2019.
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
		static let titleTextView = UIFont.systemFont(ofSize: 25, weight: .semibold)
	}

	private func hideUneditableDetails() {
		self.uneditableDetails.hide()
		self.uneditableDetailsHeightAnchor?.isActive = false
		self.uneditableDetailHeightAnchorEqualZero?.isActive = true
	}

	private func showSliderAndEditableAddress() {
		self.sliderAndEditableAddressZeroHeightAnchor?.isActive = false
		self.sliderAndEditableAddressHeightAnchor?.isActive = true
		self.sliderAndEditableAddress.show()
	}
	private func showUneditableDetails() {
		self.uneditableDetailHeightAnchorEqualZero?.isActive = false
		self.uneditableDetailsHeightAnchor?.isActive = true
		self.uneditableDetails.show()
	}

	private func hideSliderAndEditableAddress() {
		self.sliderAndEditableAddress.hide()
		self.sliderAndEditableAddressHeightAnchor?.isActive = false
		self.sliderAndEditableAddressZeroHeightAnchor?.isActive = true
	}

	var presenter: IDetailTargetPresenter
	private let router: IDetailTargetRouter
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
	private let titleTextView = UITextView()
	private let smartTargetAttendanceLabels = SmartTargetAttendanceLabels()
	private let uneditableDetails = UneditableTargetsDetails()
	private var uneditableDetailHeightAnchorEqualZero: NSLayoutConstraint?
	private var uneditableDetailsHeightAnchor: NSLayoutConstraint?
	private let sliderAndEditableAddress = SliderAndEditableAddressView()
	private var sliderAndEditableAddressHeightAnchor: NSLayoutConstraint?
	private var sliderAndEditableAddressZeroHeightAnchor: NSLayoutConstraint?
	private let buttonsBar = ButtonsBar()
	private var mapViewHeightAnchor: NSLayoutConstraint?
	private var mapViewHeightAnchorEditMode: NSLayoutConstraint?
	private var smartTargetEditable = false
	private let addresDescriptionLabel = UILabel()
	private let addressLabel = UILabel()
	private let editButton = ButtonForDetailScreen(backgroundColor: .systemBlue, frame: .zero)
	private var editButtonWidthAnchor: NSLayoutConstraint?
	private var editButtonLeadingAnchorToScrollView: NSLayoutConstraint?
	private var editButtonLeadingAnchorToCancelButton: NSLayoutConstraint?
	private let cancelButton = ButtonForDetailScreen(backgroundColor: .systemRed, frame: .zero)
	private var cancelButtonWidthAnchorEqualZero: NSLayoutConstraint?
	private var cancelButtonWidthAnchorIfEditModeEnabled: NSLayoutConstraint?

	let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: Constants.ImpactFeedbackGeneratorStyle.dropPin)
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
		get { self.sliderAndEditableAddress.address }
		set {
			self.uneditableDetails.setAddress(text: newValue)
			newValue == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
			self.sliderAndEditableAddress.address = newValue ?? ""
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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		checkUserInterfaceStyle()
	}

	// MARK: - Private methods
	private func setup() {
		self.navigationItem.largeTitleDisplayMode = .never
		setupUI()
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
															  action: #selector(hideKeyboard)))
		self.presenter.getAddressText{ [weak self] in
			self?.addressText = $0
		}
	}

	// MARK: - Setup UI
	private func setupUI() {
		setupButtonsBar()
		setupScrollView()
		setupTitleTextView()
		setupUneditableDetails()
		setupMapView()
		setupSliderAndEditableAddress()
		checkUserInterfaceStyle()
		setupShowPinButtonView()
		setupAnnotation()
		setupOverlay()
		setSmartTargetRegion(coordinate: presenter.editCoordinate, animated: false)
	}

	private func editButtonAction() {
		if self.smartTargetEditable == true {
			self.impactFeedbackGenerator.impactOccurred()
			guard let smartTargetVC = self.navigationController?.viewControllers.first as? SmartTargetListViewController
				else { return }
			self.router.popDetail(to: smartTargetVC,
								  smartTarget: presenter.saveChanges(title: self.titleTextView.text,
																	 address: addressText))
		}
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		UIView.animate(withDuration: 0.2, animations: {
			self.titleTextViewEditable()
			self.mapViewEditable()
			self.hideUneditableDetails()
			self.showSliderAndEditableAddress()
			self.scrollView.layoutIfNeeded()
		})
		self.smartTargetEditable = true
	}

	private func cancelButtonAction() {
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
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		UIView.animate(withDuration: 0.2, animations: {
			self.mapViewNotEditable()
			self.titleTextViewNotEditable()
			self.showUneditableDetails()
			self.hideSliderAndEditableAddress()
			self.scrollView.layoutIfNeeded()
		})
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
		self.smartTargetEditable = false
	}

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
			self.scrollView.bottomAnchor.constraint(equalTo: self.buttonsBar.topAnchor),
		])
		self.scrollView.contentMode = .center
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
		self.titleTextView.text = self.presenter.getTitleText()
		self.titleTextView.isUserInteractionEnabled = false
		UIView.animate(withDuration: 0.2, animations: {
			self.titleTextView.backgroundColor = .clear
		})
	}

	private func setupTitleTextView() {
		self.scrollView.addSubview(titleTextView)
		titleTextView.font = FontForDetailScreen.titleTextView
		titleTextView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.titleTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
			self.titleTextView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			self.titleTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
		])
		self.titleTextView.text = presenter.getTitleText()
		self.titleTextView.isScrollEnabled = false
		self.titleTextView.textAlignment = .center
		self.titleTextView.layer.cornerRadius = 10
		titleTextViewNotEditable()
	}
	// MARK: - mapViewEditableOrNotEditable
	private func mapViewEditable() {
		self.mapViewHeightAnchor?.isActive = false
		self.mapViewHeightAnchorEditMode?.isActive = true
		self.mapView.isUserInteractionEnabled = true
	}

	private func mapViewNotEditable() {
		self.mapViewHeightAnchorEditMode?.isActive = false
		self.mapViewHeightAnchor?.isActive = true
		self.mapView.isUserInteractionEnabled = false
	}
	// MARK: - uneditableDetails
	private func setupUneditableDetails() {
		self.uneditableDetails.translatesAutoresizingMaskIntoConstraints = false
		self.uneditableDetailHeightAnchorEqualZero = self.uneditableDetails.heightAnchor.constraint(equalToConstant: 0)
		self.uneditableDetailsHeightAnchor = self.uneditableDetails.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
		self.uneditableDetailsHeightAnchor?.isActive = true
		self.scrollView.addSubview(self.uneditableDetails)
		NSLayoutConstraint.activate([
			self.uneditableDetails.topAnchor.constraint(equalTo: self.titleTextView.bottomAnchor),
			self.uneditableDetails.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
															constant: 16),
			self.uneditableDetails.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
															 constant: -16),
		])
		self.uneditableDetails.setDateOfCreationText(presenter.getDateOfCreation())
		self.uneditableDetails.setInfoOfAttendance(numberOfVisits: self.presenter.totalNumberOfVisits,
												   totalStay: self.presenter.totalStay,
												   dateOfLastVisit: self.presenter.dateOfLastVisit)
	}
	// MARK: - setupMapView
	private func setupMapView() {
		self.scrollView.addSubview(mapView)
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		let topAnchor = self.mapView.topAnchor.constraint(equalTo: self.uneditableDetails.bottomAnchor,
														  constant: 20)
		topAnchor.priority = .required
		self.mapViewHeightAnchorEditMode =
			self.mapView.heightAnchor.constraint(greaterThanOrEqualToConstant: ScreenProperties.height / 1.5)
		self.mapViewHeightAnchor =
			self.mapView.heightAnchor.constraint(greaterThanOrEqualToConstant: ScreenProperties.height / 2)
		NSLayoutConstraint.activate([
			topAnchor,
			self.mapView.widthAnchor.constraint(equalToConstant: ScreenProperties.width),
			self.mapView.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
		])
		self.mapViewNotEditable()
	}
	// MARK: - setupSliderAndEditableAddress
	private func setupSliderAndEditableAddress() {
		self.mapView.addSubview(sliderAndEditableAddress)
		self.sliderAndEditableAddress.translatesAutoresizingMaskIntoConstraints = false
		self.sliderAndEditableAddressZeroHeightAnchor =
			self.sliderAndEditableAddress.heightAnchor.constraint(equalToConstant: 0)
		self.sliderAndEditableAddressHeightAnchor =
			self.sliderAndEditableAddress.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
		self.sliderAndEditableAddressZeroHeightAnchor?.isActive = true
		NSLayoutConstraint.activate([
			self.sliderAndEditableAddress.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
																   constant: 16),
			self.sliderAndEditableAddress.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
																	constant: -16),
			self.sliderAndEditableAddress.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor,
																  constant: -10),
		])
	}
	// MARK: - setupButtonsBar
	private func setupButtonsBar() {
		self.view.addSubview(buttonsBar)
		self.buttonsBar.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.buttonsBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.buttonsBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.buttonsBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.buttonsBar.heightAnchor.constraint(equalToConstant: 80),
		])
		self.buttonsBar.addActionForCancelButton { self.cancelButtonAction() }
		self.buttonsBar.addActionForEditButton { self.editButtonAction() }
	}
	// MARK: - setupShowPinButtonView
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
}
// MARK: - Actions
private extension DetailTargetViewController
{
	func actionShowPin() {
		setSmartTargetRegion(coordinate: presenter.editCoordinate, animated: true)
	}
}
