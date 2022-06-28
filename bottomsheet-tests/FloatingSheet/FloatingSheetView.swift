//
//  FloatingSheetView.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 27.06.2022.
//

import QuartzCore
import UIKit

final class FloatingSheetView: UIView {
    private let overlayView: UIView = UIView()
    private let floatingView: UIView = UIView()
    private let contentContainer: UIView = UIView()
    private var contentView: UIView?
    private var states: [FloatingSheetState] = []
    private var currentState: FloatingSheetState?

    private var maskLayer: CALayer = .init()
    private var shadowLayer: CALayer = .init()

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
        let newFrame = currentState.position.frame(context)

        let frame = currentState.mask.mask(context) ?? floatingView.bounds
        let cornerRadius = currentState.appearance.cornerRadius
        let position = CGPoint(
            x: 0.5 * frame.width + frame.origin.x,
            y: 0.5 * frame.height + frame.origin.y
        )
        let bounds = CGRect(origin: .zero, size: frame.size)

        updateAnimated(animated) {
            self.floatingView.frame = newFrame
            self.overlayView.backgroundColor = currentState.appearance.overlayColor

            self.shadowLayer.shadowColor = currentState.appearance.shadow.color?.cgColor
            self.shadowLayer.shadowOffset = currentState.appearance.shadow.offset
            self.shadowLayer.shadowRadius = currentState.appearance.shadow.radius
            self.shadowLayer.shadowOpacity = currentState.appearance.shadow.opacity
            self.shadowLayer.position = position
            self.shadowLayer.cornerRadius = cornerRadius
            self.shadowLayer.bounds = bounds

            self.floatingView.layoutIfNeeded()
        }

        if animated {
            CATransaction.begin()
            animateLayer(layer: maskLayer, keyPath: "cornerRadius", oldValue: maskLayer.cornerRadius, newValue: cornerRadius)
            animateLayer(layer: maskLayer, keyPath: "position", oldValue: maskLayer.position, newValue: position)
            animateLayer(layer: maskLayer, keyPath: "bounds", oldValue: maskLayer.bounds, newValue: bounds)
            CATransaction.commit()
        } else {
            maskLayer.cornerRadius = cornerRadius
            maskLayer.position = position
            maskLayer.bounds = bounds
        }
    }

    private func animateLayer<Value>(
        layer: CALayer,
        keyPath: String,
        oldValue: Value,
        newValue: Value
    ) {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = oldValue
        animation.toValue = newValue
        animation.duration = 0.25
        animation.timingFunction = .init(name: .easeOut)
        layer.add(animation, forKey: keyPath)
    }

    private func updateAnimated(_ animated: Bool, actions: @escaping () -> Void) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: actions)
        } else {
            actions()
        }
    }
}
