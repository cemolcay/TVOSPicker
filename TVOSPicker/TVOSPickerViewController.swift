//
//  TVOSPickerViewController.swift
//  TVOSPicker
//
//  Created by Cem Olcay on 08/05/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

public class TVOSPickerCell: UICollectionViewCell {
  public static let cellReuseIdentifier = "PickerCell"
  public var titleLabel = UILabel()
  public var focusedScale: CGFloat = 1.2
  public var pressedScale: CGFloat = 0.9

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    titleLabel.textAlignment = .center
    titleLabel.textColor = .black
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
      titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
    ])
  }

  public override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
  }

  public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    super.pressesBegan(presses, with: event)
    spring(animations: {
      self.layer.transform = CATransform3DMakeScale(self.pressedScale, self.pressedScale, 1)
    })
  }

  public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    super.pressesEnded(presses, with: event)
    spring(animations: {
      self.layer.transform = CATransform3DMakeScale(self.focusedScale, self.focusedScale, 1)
    })
  }

  public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    backgroundColor = isFocused ? .lightGray : .clear
    if self == context.nextFocusedView {
      coordinator.addCoordinatedAnimations({
        self.layer.transform = CATransform3DMakeScale(self.focusedScale, self.focusedScale, 1)
      }, completion: nil)
    } else if self == context.previouslyFocusedView {
      coordinator.addCoordinatedAnimations({
        self.layer.transform = CATransform3DIdentity
      }, completion: nil)
    }
  }

  private func spring(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: .allowAnimatedContent,
      animations: animations,
      completion: completion)
  }
}

public protocol TVOSPickerViewControllerDelegate: class {
  func pickerViewController(_ pickerViewController: TVOSPickerViewController, didSelect item: String, at index: Int)
  func pickerViewControllerDidPressCancelButton(_ pickerViewController: TVOSPickerViewController)
}

public class TVOSPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  public var titleLabel = UILabel()
  public var subtitleLabel = UILabel()
  public var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  public var cancelButton = UIButton(type: .system)

  public var dataSource: [String] = []
  public var defaultSelectedItemIndex = 0
  private var contentStack = UIStackView()
  private let cancelFocusGuide = UIFocusGuide()

  public weak var delegate: TVOSPickerViewControllerDelegate?

  private lazy var contentWidth: CGFloat = {
    return Array(0..<self.collectionView.numberOfItems(inSection: 0))
      .map({ self.collectionView(self.collectionView, layout: self.collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: $0, section: 0)).width })
      .reduce(0, +)
  }()

  // MARK: Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    let topEmptyView = UIView()
    topEmptyView.translatesAutoresizingMaskIntoConstraints = false
    topEmptyView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .horizontal)
    topEmptyView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .vertical)

    let bottomEmptyView = UIView()
    bottomEmptyView.translatesAutoresizingMaskIntoConstraints = false
    bottomEmptyView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .horizontal)
    bottomEmptyView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .vertical)

    // Stack view
    view.addSubview(contentStack)
    contentStack.axis = .vertical
    contentStack.alignment = .center
    contentStack.spacing = 16
    contentStack.addArrangedSubview(topEmptyView)
    contentStack.addArrangedSubview(titleLabel)
    contentStack.addArrangedSubview(subtitleLabel)
    contentStack.addArrangedSubview(collectionView)
    contentStack.addArrangedSubview(cancelButton)
    contentStack.addArrangedSubview(bottomEmptyView)

    contentStack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100),
      contentStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100),
      contentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    ])

    topEmptyView.heightAnchor.constraint(equalTo: bottomEmptyView.heightAnchor, multiplier: 1).isActive = true

    // Title label
    titleLabel.textAlignment = .center
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
    titleLabel.textColor = .black
    titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 240), for: .horizontal)
    titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 240), for: .vertical)

    // Subtitle label
    subtitleLabel.textAlignment = .center
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    subtitleLabel.textColor = .black
    subtitleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 230), for: .horizontal)
    subtitleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 230), for: .vertical)

    // Collection view
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(TVOSPickerCell.self, forCellWithReuseIdentifier: TVOSPickerCell.cellReuseIdentifier)

    NSLayoutConstraint.activate([
      collectionView.heightAnchor.constraint(equalToConstant: 125),
      collectionView.leftAnchor.constraint(equalTo: contentStack.leftAnchor, constant: 0),
      collectionView.rightAnchor.constraint(equalTo: contentStack.rightAnchor, constant: 0)
    ])

    let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    flow?.minimumLineSpacing = 1000
    flow?.minimumInteritemSpacing = 10
    flow?.scrollDirection = .horizontal

    // Cancel button
    cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel button title"), for: .normal)
    cancelButton.addTarget(self, action: #selector(cancelButtonPressed(sender:)), for: .primaryActionTriggered)

    // Setup focus guide
    view.addLayoutGuide(cancelFocusGuide)
    cancelFocusGuide.preferredFocusedView = cancelButton
    NSLayoutConstraint.activate([
      cancelFocusGuide.leftAnchor.constraint(equalTo: contentStack.leftAnchor),
      cancelFocusGuide.rightAnchor.constraint(equalTo: contentStack.rightAnchor),
      cancelFocusGuide.topAnchor.constraint(equalTo: cancelButton.topAnchor),
      cancelFocusGuide.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor)
    ])

    collectionView.reloadData()
  }

  @objc func cancelButtonPressed(sender: UIButton) {
    delegate?.pickerViewControllerDidPressCancelButton(self)
  }

  // MARK: Focus

  public override var preferredFocusEnvironments: [UIFocusEnvironment] {
    guard let cell = collectionView.cellForItem(
      at: IndexPath(item: defaultSelectedItemIndex, section: 0))
      else { return [] }
    return [cell]
  }

  public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    guard let cell = context.nextFocusedView as? TVOSPickerCell,
      let indexPath = collectionView.indexPath(for: cell)
      else { return }

    // Center cells when scrolling
    if contentWidth > collectionView.frame.size.width {
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    // Setup focus guide
    if context.nextFocusedView == cancelButton {
      cancelFocusGuide.preferredFocusedView = collectionView
    } else if context.nextFocusedView == collectionView {
      cancelFocusGuide.preferredFocusedView = cancelButton
    }
  }

  // MARK: UICollectionViewDataSource

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TVOSPickerCell.cellReuseIdentifier,
      for: indexPath) as? TVOSPickerCell
      else { fatalError() }

    cell.titleLabel.text = dataSource[indexPath.row]
    cell.layer.cornerRadius = 10
    cell.layer.masksToBounds = true

    return cell
  }

  // MARK: UICollectionViewDelegate

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = dataSource[indexPath.item]
    delegate?.pickerViewController(self, didSelect: item, at: indexPath.item)
  }

  // MARK: UICollectionViewDelegateFlowLayout

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let item = dataSource[indexPath.item]
    let itemWidth = NSAttributedString(
      string: item,
      attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body)]
    ).boundingRect(
        with: CGSize(width: .max, height: .max),
        options: .usesDeviceMetrics,
        context: nil)
    .width
    return CGSize(width: itemWidth + 80, height: collectionView.frame.size.height - 40)
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    if contentWidth > collectionView.frame.size.width {
      return .zero
    }

    let padding = (collectionView.frame.size.width - contentWidth) / 2
    return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
  }
}

public typealias TVOSPickerHandler = (_ item: String, _ at: Int) -> Void
public var TVOSPickerHandlerAssociatedObject: UInt8 = 0
extension UIViewController: TVOSPickerViewControllerDelegate {

  private var pickerHandler: TVOSPickerHandler? {
    get {
      return objc_getAssociatedObject(self, &TVOSPickerHandlerAssociatedObject) as? TVOSPickerHandler
    } set {
      objc_setAssociatedObject(self, &TVOSPickerHandlerAssociatedObject, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public func pickerViewControllerDidPressCancelButton(_ pickerViewController: TVOSPickerViewController) {
    if let navigationController = navigationController {
      navigationController.popViewController(animated: true)
    } else {
      pickerViewController.dismiss(animated: true, completion: nil)
    }
  }

  public func pickerViewController(_ pickerViewController: TVOSPickerViewController, didSelect item: String, at index: Int) {
    pickerHandler?(item, index)
    pickerViewControllerDidPressCancelButton(pickerViewController)
  }

  public func presentPicker(title: String, subtitle: String? = nil, dataSource: [String], initialSelection: Int = 0, onSelectItem: @escaping TVOSPickerHandler) {
    let picker = TVOSPickerViewController()
    picker.titleLabel.text = title
    picker.subtitleLabel.text = subtitle
    picker.dataSource = dataSource
    picker.defaultSelectedItemIndex = initialSelection
    picker.delegate = self
    pickerHandler = onSelectItem
    if let navigationController = navigationController {
      navigationController.pushViewController(picker, animated: true)
    } else {
      present(picker, animated: true, completion: nil)
    }
  }
}
