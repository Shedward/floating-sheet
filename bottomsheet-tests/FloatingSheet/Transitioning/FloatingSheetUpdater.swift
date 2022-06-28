//
//  FloatingSheetUpdater.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetUpdater {
    private let animationDuration: TimeInterval = 0.25
    private let sheetView: FloatingSheetView
    private let context: FloatingSheetContext
    private let currentState: FloatingSheetState

    init(sheetView: FloatingSheetView, context: FloatingSheetContext, to currentState: FloatingSheetState) {
        self.sheetView = sheetView
        self.context = context
        self.currentState = currentState
    }

    func updateState(animated: Bool) {
        updateView(animated: animated) {
            updatePosition()
            updateOverlayAppearance()
            updateShadow()
            sheetView.floatingView.layoutIfNeeded()
        }

        updateMask(animated: animated)
    }

    private func updatePosition() {
        let newFrame = currentState.position.frame(context)
        sheetView.floatingView.frame = newFrame
    }

    private func updateOverlayAppearance() {
        sheetView.overlayView.backgroundColor = currentState.appearance.overlayColor
    }

    private func updateMask(animated: Bool) {
        let frame = currentState.mask.mask(context) ?? sheetView.floatingView.bounds
        let cornerRadius = currentState.appearance.cornerRadius
        let position = CGPoint(
            x: 0.5 * frame.width + frame.origin.x,
            y: 0.5 * frame.height + frame.origin.y
        )
        let bounds = CGRect(origin: .zero, size: frame.size)

        if animated {
            CATransaction.begin()
            animateLayer(layer: sheetView.maskLayer, keyPath: "cornerRadius", oldValue: sheetView.maskLayer.cornerRadius, newValue: cornerRadius)
            animateLayer(layer: sheetView.maskLayer, keyPath: "position", oldValue: sheetView.maskLayer.position, newValue: position)
            animateLayer(layer: sheetView.maskLayer, keyPath: "bounds", oldValue: sheetView.maskLayer.bounds, newValue: bounds)
            CATransaction.commit()

            updateView(animated: true) {
                sheetView.shadowLayer.position = position
                sheetView.shadowLayer.cornerRadius = cornerRadius
                sheetView.shadowLayer.bounds = bounds
            }
        } else {
            sheetView.maskLayer.cornerRadius = cornerRadius
            sheetView.maskLayer.position = position
            sheetView.maskLayer.bounds = bounds

            sheetView.shadowLayer.position = position
            sheetView.shadowLayer.cornerRadius = cornerRadius
            sheetView.shadowLayer.bounds = bounds
        }
    }

    private func updateShadow() {
        sheetView.shadowLayer.shadowColor = currentState.appearance.shadow.color?.cgColor
        sheetView.shadowLayer.shadowOffset = currentState.appearance.shadow.offset
        sheetView.shadowLayer.shadowRadius = currentState.appearance.shadow.radius
        sheetView.shadowLayer.shadowOpacity = currentState.appearance.shadow.opacity
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
        animation.duration = animationDuration
        animation.timingFunction = .init(name: .easeOut)
        layer.add(animation, forKey: keyPath)
    }

    private func updateView(animated: Bool, _ actions: @escaping () -> Void) {
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                options: [.curveEaseOut]
            ) {
                actions()
            }
        } else {
            actions()
        }
    }
}
