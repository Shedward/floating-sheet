//
//  FloatingSheetDraggingBehaviour.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

class FloatingSheetDraggingBehaviour: NSObject {
    private weak var sheetView: FloatingSheetView?
    private let states: [FloatingSheetState]

    private var currentTransition: Transition?

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(didPanFloatingSheet(recognizer:)))
        recognizer.delegate = self
        return recognizer
    }()

    init(in sheetView: FloatingSheetView, states: [FloatingSheetState]) {
        self.sheetView = sheetView
        self.states = states

        super.init()

        sheetView.floatingView.addGestureRecognizer(panGestureRecognizer)
    }

    deinit {
        sheetView?.floatingView.removeGestureRecognizer(panGestureRecognizer)
    }
}

extension FloatingSheetDraggingBehaviour {

    @objc private func didPanFloatingSheet(recognizer: UIPanGestureRecognizer) {
        guard let sheetView = sheetView else { return }

        let position = recognizer.location(in: sheetView)
        let gesture = Gesture(center: position)

        switch recognizer.state {
        case .began:
            startTransition(gesture: gesture)
        case .changed:
            updateTransition(gesture: gesture)
        case .ended, .cancelled, .failed:
            finishTransition(gesture: gesture)
        case .possible:
            break
        @unknown default:
            break
        }
    }

    private func startTransition(gesture: Gesture) {
        guard currentTransition == nil else { return }
        guard let context = sheetView?.currentContext() else { return }
        guard let currentState = sheetView?.currentState else { return }
        guard let nextState = closestState(for: gesture, except: currentState) else { return }

        let animator = UIViewPropertyAnimator(duration: FloatingSheetUpdater.animationDuration, curve: .easeOut)
        animator.addAnimations {
            self.sheetView?.setCurrentState(nextState, animated: true)
        }
        animator.startAnimation()

        currentTransition = .init(
            animator: animator,
            initialGesture: gesture,
            initialState: currentState,
            initialPosition: anchorPoint(for: currentState.position.frame(context)),
            finalState: nextState,
            finalPosition: anchorPoint(for: nextState.position.frame(context))
        )
    }

    private func updateTransition(gesture: Gesture) {
        guard let currentTransition = currentTransition else { return }
        let fractionComplete = currentTransition.progress(for: gesture)
        currentTransition.animator.fractionComplete = fractionComplete
        print("Update transition fractionComplete: \(fractionComplete)")
    }

    private func finishTransition(gesture: Gesture) {
        guard let currentTransition = currentTransition else { return }

        currentTransition.animator.addAnimations {
            self.sheetView?.setCurrentState(currentTransition.finalState, animated: false)
        }

        self.currentTransition = nil
    }

    private func closestState(for gesture: Gesture, except excludingState: FloatingSheetState? = nil) -> FloatingSheetState? {
        guard let context = sheetView?.currentContext() else { return nil }

        let gravitationPoints = states
            .filter { $0.id != excludingState?.id }
            .map { state -> GravitationPoint in
                let frame = state.position.frame(context)
                let expectedCenter = anchorPoint(for: frame)

                let distance = gesture.center.distance(to: expectedCenter)
                let force = state.gravityCoefficient / (distance * distance + 1)
                return GravitationPoint(
                    center: expectedCenter,
                    state: state,
                    force: force
                )
            }

        let strongestPoint = gravitationPoints.max { $0.force < $1.force }
        return strongestPoint?.state
    }

    private func anchorPoint(for frame: CGRect) -> CGPoint {
        frame.origin
    }
}

extension FloatingSheetDraggingBehaviour {
    private struct Gesture {
        let center: CGPoint
        
    }

    private struct GravitationPoint {
        let center: CGPoint
        let state: FloatingSheetState
        let force: CGFloat
    }

    private struct Transition {
        let animator: UIViewPropertyAnimator
        let initialGesture: Gesture
        let initialState: FloatingSheetState
        let initialPosition: CGPoint
        let finalState: FloatingSheetState
        let finalPosition: CGPoint

        func progress(for gesture: Gesture) -> CGFloat {
            let gestureDelta = initialGesture.center - initialPosition
            let gesturePosition = gesture.center - gestureDelta
            let progress = (gesturePosition.y - initialPosition.y) / (finalPosition.y - initialPosition.y)
            return progress
        }
    }
}

extension FloatingSheetDraggingBehaviour: UIGestureRecognizerDelegate {
}
