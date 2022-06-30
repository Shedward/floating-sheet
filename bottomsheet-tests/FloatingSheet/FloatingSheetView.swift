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
    let contentContainer: UIView = UIView()

    private(set) var contentView: UIView?
    private(set) var currentState: FloatingSheetState?

    private var transitionBehaviour = FloatingSheetTransitionBehaviour()
    private let panGestureRecognizer = UIPanGestureRecognizer()

    var shouldUpdateAfterLayout: Bool = true

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

        shadowView.backgroundColor = .white
        floatingView.clipsToBounds = false
        floatingView.insertSubview(shadowView, belowSubview: contentContainer)


        maskingView.frame = contentContainer.bounds
        maskingView.backgroundColor = .white
        contentContainer.mask = maskingView

        floatingView.addSubview(contentContainer)

        addSubview(floatingView)
        panGestureRecognizer.addTarget(self, action: #selector(didPanFloatingView(recognizer:)))
        floatingView.addGestureRecognizer(panGestureRecognizer)

        transitionBehaviour.view = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if shouldUpdateAfterLayout {
            shouldUpdateAfterLayout = false
            updateUI(to: currentState)
        }
    }

    func setContent(_ contentView: UIView) {
        self.contentView?.removeFromSuperview()
        self.contentView = contentView
        contentView.autoresizingMask = []
        contentView.frame = contentContainer.bounds
        contentContainer.addSubview(contentView)
        updateUI(to: currentState)
    }

    func setStates(_ states: [FloatingSheetState]) {
        transitionBehaviour.states = states
    }

    func setCurrentState(_ state: FloatingSheetState, animated: Bool) {
        if animated, let currentState = currentState {
            transitionBehaviour.startTransition(from: currentState, to: state)
        } else {
            currentState = state
            updateUI(to: state)
        }
    }

    func updateUI(to state: FloatingSheetState?) {
        let updater = FloatingSheetUpdater(sheetView: self, to: state)
        updater?.update()
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

    @objc private func didPanFloatingView(recognizer: UIPanGestureRecognizer) {
        let position = recognizer.location(in: self)
        let velocity = recognizer.velocity(in: self)
        let gesture = Gesture(center: position, velocity: velocity)

        transitionBehaviour.didPan(state: recognizer.state, gesture: gesture)
    }
}
