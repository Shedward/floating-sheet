//
//  FloatingSheetView.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 27.06.2022.
//

import QuartzCore
import UIKit

final class FloatingSheetView: UIView {
    let overlayView: UIView = UIView()
    let floatingView: UIView = UIView()
    let maskLayer: CALayer = .init()
    let shadowLayer: CALayer = .init()

    private var contentView: UIView?
    private let contentContainer: UIView = UIView()
    private var states: [FloatingSheetState] = []
    private var currentState: FloatingSheetState?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear

        addSubview(overlayView)
        overlayView.edgesToSuperview()

        maskLayer.bounds = bounds
        maskLayer.backgroundColor = UIColor.black.cgColor
        contentContainer.layer.mask = maskLayer

        shadowLayer.backgroundColor = UIColor.black.cgColor
        floatingView.layer.insertSublayer(shadowLayer, below: contentContainer.layer)

        floatingView.addSubview(contentContainer)
        contentContainer.edgesToSuperview()

        addSubview(floatingView)
        updateState(animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateState(animated: false)
    }

    func setContent(_ contentView: UIView) {
        self.contentView?.removeFromSuperview()
        self.contentView = contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(contentView)
        contentView.leadingToSuperview()
        contentView.topToSuperview()
        contentView.trailingToSuperview(priority: .init(rawValue: 999))
        contentView.bottomToSuperview(prority: .init(rawValue: 999))
        updateState(animated: false)
    }

    func setStates(_ states: [FloatingSheetState]) {
        self.states = states
    }

    func setCurrentState(_ state: FloatingSheetState, animated: Bool) {
        currentState = state
        updateState(animated: animated)
    }

    private func updateState(animated: Bool) {
        guard
            let contentView = contentView,
            let currentState = currentState
        else {
            return
        }

        let context = FloatingSheetContext(
            availableSize: overlayView.bounds.size,
            contentView: contentView
        )

        let updater = FloatingSheetUpdater(sheetView: self, context: context, to: currentState)
        updater.updateState(animated: animated)
    }
}
