//
//  FloatingSheetTransitionBehaviour.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit
import simd

class FloatingSheetTransitionBehaviour: NSObject {
    private let animationDuration: TimeInterval = 0.25
    private let timing = UISpringTimingParameters(damping: 0.9, response: 0.5)

    weak var view: FloatingSheetView?

    var states: [FloatingSheetState] = []
    private var currentTransition: Transition?
}

extension FloatingSheetTransitionBehaviour {
    func startTransition(
        from initialState: FloatingSheetState,
        to nextState: FloatingSheetState
    ) {
        currentTransition?.animator.stopAnimation(false)
        let animator = transitionAnimator(from: initialState, to: nextState)
        animator.startAnimation()
    }


    private func transitionAnimator(
        from initialState: FloatingSheetState,
        to nextState: FloatingSheetState
    ) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(
            duration: animationDuration,
            timingParameters: timing
        )
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            self.view?.updateUI(to: nextState)
        }
        animator.addCompletion { [weak self] position in
            guard let self = self else { return }
            switch position {
            case .end:
                self.view?.setCurrentState(nextState, animated: false)
            case .start:
                self.view?.setCurrentState(initialState, animated: false)
            case .current:
                break
            @unknown default:
                break
            }
        }

        return animator
    }
}

extension FloatingSheetTransitionBehaviour {

    func didPan(state: UIGestureRecognizer.State, gesture: Gesture) {
        switch state {
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
        if currentTransition == nil {
            guard let initialState = view?.currentState else { return }
            guard let nextState = nextExpectedState(from: initialState, for: gesture) else { return }

            let animator = transitionAnimator(from: initialState, to: nextState)
            animator.pauseAnimation()

            currentTransition = .init(
                animator: animator,
                initialGesture: gesture,
                initialState: initialState,
                initialPosition: position(for: initialState),
                finalState: nextState,
                finalPosition: position(for: nextState)
            )
        } else {
            currentTransition?.animator.pauseAnimation()
        }
    }

    private func updateTransition(gesture: Gesture) {
        guard let currentTransition = currentTransition else { return }
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

extension FloatingSheetTransitionBehaviour {

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
        guard let context = view?.currentContext() else { return .zero }
        let frame = state.position.frame(context)
        return frame.origin
    }

    private func positionedStates() -> [PositionedState] {
        states.map { PositionedState(state: $0, position: position(for: $0)) }
    }
}

extension FloatingSheetTransitionBehaviour {
    private struct PositionedState {
        let state: FloatingSheetState
        let position: CGPoint
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
