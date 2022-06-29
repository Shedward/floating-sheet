//
//  FloatingSheetDraggingBehaviour.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit
import simd

class FloatingSheetDraggingBehaviour: NSObject {
    private weak var sheetView: FloatingSheetView?
    private let states: [FloatingSheetState]

    private var currentTransition: Transition?

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(didPanFloatingSheet(recognizer:)))
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
        let velocity = recognizer.velocity(in: sheetView)
        let gesture = Gesture(center: position, velocity: velocity)

        switch recognizer.state {
        case .began:
            startTransition(gesture: gesture)
        case .changed:
            updateTransition(gesture: gesture)
        case .ended:
            finishTransition(gesture: gesture, isCanceled: false)
        case .cancelled, .failed:
            finishTransition(gesture: gesture, isCanceled: true)
        case .possible:
            break
        @unknown default:
            break
        }
    }

    private func startTransition(gesture: Gesture) {
        guard currentTransition == nil else { return }
        guard let currentState = sheetView?.currentState else { return }
        guard let nextState = nextExpectedState(from: currentState, for: gesture) else { return }

        let animator = UIViewPropertyAnimator(duration: FloatingSheetUpdater.animationDuration, curve: .easeOut)
        animator.addAnimations {
            self.sheetView?.setCurrentState(nextState, animated: false)
        }
        animator.startAnimation()

        currentTransition = .init(
            animator: animator,
            initialGesture: gesture,
            initialState: currentState,
            initialPosition: position(for: currentState),
            finalState: nextState,
            finalPosition: position(for: nextState)
        )
    }

    private func updateTransition(gesture: Gesture) {
        guard let currentTransition = currentTransition else { return }
        currentTransition.animator.pauseAnimation()
        let fractionComplete = currentTransition.progress(for: gesture)
        currentTransition.animator.fractionComplete = fractionComplete
    }

    private func finishTransition(gesture: Gesture, isCanceled: Bool) {
        guard let currentTransition = currentTransition else { return }

        let shouldReverseTransition: Bool
        if isCanceled {
            shouldReverseTransition = true
        } else {
            let projectedFinalPosition = currentTransition.projectedPosition(for: gesture)
            let closesState = closestState(to: projectedFinalPosition)
            shouldReverseTransition = closesState == currentTransition.initialState
        }

        currentTransition.animator.isReversed = shouldReverseTransition
        currentTransition.animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        self.currentTransition = nil
    }

}

extension FloatingSheetDraggingBehaviour {

    private func nextExpectedState(from currentState: FloatingSheetState, for gesture: Gesture) -> FloatingSheetState? {
        let currentPosition = position(for: currentState)

        let possibleStatesOrderedByY = positionedStates()
            .filter { $0.state != currentState }
            .sorted { $0.position.y < $1.position.y }

        let nextState: FloatingSheetState?

        if gesture.velocity.y > 0 {
            nextState = possibleStatesOrderedByY
                .first { $0.position.y > currentPosition.y }
                .map { $0.state }
        } else {
            nextState = possibleStatesOrderedByY
                .reversed()
                .first { $0.position.y < currentPosition.y }
                .map { $0.state }
        }

        return nextState
    }

    private func closestState(to position: CGPoint) -> FloatingSheetState? {
        let yDistanceTo = { (positionedState: PositionedState) -> CGFloat in
            abs(positionedState.position.y - position.y)
        }
        let closestState = positionedStates()
            .min { yDistanceTo($0) < yDistanceTo($1) }
            .map { $0.state }

        return closestState
    }

    private func position(for state: FloatingSheetState) -> CGPoint {
        guard let context = sheetView?.currentContext() else { return .zero }
        let frame = state.position.frame(context)
        return frame.origin
    }

    private func positionedStates() -> [PositionedState] {
        states.map { PositionedState(state: $0, position: position(for: $0)) }
    }
}

extension FloatingSheetDraggingBehaviour {
    private struct PositionedState {
        let state: FloatingSheetState
        let position: CGPoint
    }

    private struct Gesture {
        var center: CGPoint
        var velocity: CGPoint

        func projectedStopPoint() -> CGPoint {
            let acceleration: CGFloat = -900
            let accelerationVector = CGPoint(
                x: acceleration * sign(velocity.x),
                y: acceleration * sign(velocity.y)
            )

            let projectedPoint = CGPoint(
                x: center.x - 0.5 * velocity.x * velocity.x / accelerationVector.x,
                y: center.y - 0.5 * velocity.y * velocity.y / accelerationVector.y
            )

            return projectedPoint
        }
    }

    private struct Transition {
        let animator: UIViewPropertyAnimator
        let initialGesture: Gesture
        let initialState: FloatingSheetState
        let initialPosition: CGPoint
        let finalState: FloatingSheetState
        let finalPosition: CGPoint

        func position(for gesture: Gesture) -> CGPoint {
            let gestureDelta = initialGesture.center - initialPosition
            let position = gesture.center - gestureDelta
            return position
        }

        func projectedPosition(for gesture: Gesture) -> CGPoint {
            let normalizedGesture = Gesture(center: position(for: gesture), velocity: gesture.velocity)
            return normalizedGesture.projectedStopPoint()
        }

        func progress(for gesture: Gesture) -> CGFloat {
            let gesturePosition = position(for: gesture)
            let progress = (gesturePosition.y - initialPosition.y) / (finalPosition.y - initialPosition.y)
            return progress
        }
    }
}
