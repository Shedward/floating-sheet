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
    let maskingView: UIView = UIView()
    let shadowView: UIView = .init()

    private(set) var currentState: FloatingSheetState?

    private var contentView: UIView?
    private let contentContainer: UIView = UIView()
    private var states: [FloatingSheetState] = []
    private var draggingBehaviour: FloatingSheetDraggingBehaviour?

    private var isLayoutedInitially: Bool = false

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

        floatingView.insertSubview(shadowView, belowSubview: contentContainer)
        maskingView.frame = contentContainer.bounds
        maskingView.backgroundColor = .white
        contentContainer.mask = maskingView

        floatingView.addSubview(contentContainer)
        contentContainer.edgesToSuperview()

        addSubview(floatingView)
        updateState(animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isLayoutedInitially {
            updateState(animated: false)
            isLayoutedInitially = true
        }

        if let currentState = currentState {
            let updater = createUpdater(to: currentState)
            updater?.updateAnimated {
                updater?.updateMask()
            }
        }
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

        draggingBehaviour = FloatingSheetDraggingBehaviour(in: self, states: states)
    }

    func setCurrentState(_ state: FloatingSheetState, animated: Bool) {
        guard state.id != currentState?.id else { return }
        currentState = state
        updateState(animated: animated)
    }

    private func updateState(animated: Bool) {
        guard let currentState = currentState else { return }

        let updater = createUpdater(to: currentState)
        updater?.updateState(animated: animated)
    }

    func createUpdater(to state: FloatingSheetState) -> FloatingSheetUpdater? {
        guard let context = currentContext() else { return nil }

        let updater = FloatingSheetUpdater(sheetView: self, context: context, to: state)
        return updater
    }

    func currentContext() -> FloatingSheetContext? {
        guard let contentView = contentView else {
            return nil
        }

        let context = FloatingSheetContext(
            availableSize: overlayView.bounds.size,
            contentView: contentView
        )

        return context
    }
}
