//
//  FloatingSheetUpdater.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetUpdater {
    static let animationDuration: TimeInterval = 0.25

    private let sheetView: FloatingSheetView
    private let context: FloatingSheetContext
    private let currentState: FloatingSheetState

    init(sheetView: FloatingSheetView, context: FloatingSheetContext, to currentState: FloatingSheetState) {
        self.sheetView = sheetView
        self.context = context
        self.currentState = currentState
    }

    func updateState(animated: Bool) {
        print("FloatingSheetUpdater.updateState(animated: \(animated)), state = \(currentState.id)")

        updateAnimated(animated) {
            updatePosition()
            print("FloatingSheetUpdater.floatingView.layoutIfNeeded()")
            sheetView.floatingView.layoutIfNeeded()
            updateOverlayAppearance()
            updateShadow()
            updateMask()
        }
    }

    func updatePosition() {
        let newFrame = currentState.position.frame(context)
        print("FloatingSheetUpdater.updatePosition frame = \(newFrame)")
        sheetView.floatingView.frame = newFrame
    }

    func updateOverlayAppearance() {
        print("FloatingSheetUpdater.updateOverlayAppearance")
        sheetView.overlayView.backgroundColor = currentState.appearance.overlayColor
    }

    func updateMask() {
        print("FloatingSheetUpdater.updateMask")
        let frame = currentState.mask.mask(context) ?? sheetView.floatingView.bounds
        let cornerRadius = currentState.appearance.cornerRadius

        sheetView.maskingView.layer.cornerRadius = cornerRadius
        sheetView.maskingView.frame = frame

        sheetView.shadowView.layer.cornerRadius = cornerRadius
        sheetView.shadowView.frame = frame
    }

    func updateShadow() {
        print("FloatingSheetUpdater.updateShadow")
        sheetView.shadowView.layer.shadowColor = currentState.appearance.shadow.color?.cgColor
        sheetView.shadowView.layer.shadowOffset = currentState.appearance.shadow.offset
        sheetView.shadowView.layer.shadowRadius = currentState.appearance.shadow.radius
        sheetView.shadowView.layer.shadowOpacity = currentState.appearance.shadow.opacity
    }

    func updateAnimated(_ animated: Bool = true, _ actions: @escaping () -> Void) {
        if animated {
            UIView.animate(
                withDuration: Self.animationDuration,
                delay: 0,
                options: [.curveEaseOut, .layoutSubviews]
            ) {
                actions()
            }
        } else {
            actions()
        }
    }
}
