//
//  FloatingSheetView.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 27.06.2022.
//

import UIKit

final class FloatingSheetView: UIView {
    private let overlayView: UIView = UIView()
    private let contentContainer: UIView = UIView()
    private var contentView: UIView?
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

        addSubview(contentContainer)
        updateState()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateState()
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
        updateState()
    }

    func setStates(_ states: [FloatingSheetState]) {
        self.states = states
    }

    func setCurrentState(_ state: FloatingSheetState) {
        currentState = state
        updateState()
    }

    private func updateState() {
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
        let newFrame = currentState.position.frame(context)
        contentContainer.frame = newFrame
    }
}
