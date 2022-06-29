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
        guard let context = sheetView?.currentContext() else { return }
        guard let currentState = sheetView?.currentState else { return }
        guard let nextState = closestState(for: gesture, except: currentState) else { return }

        let animator = UIViewPropertyAnimator(duration: FloatingSheetUpdater.animationDuration, curve: .easeOut)
        animator.addAnimations {
            self.sheetView?.setCurrentState(nextState, animated: false)
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
            let closesState = closestState(for: gesture, in: currentTransition)
            shouldReverseTransition = closesState == currentTransition.initialState
        }

        currentTransition.animator.isReversed = shouldReverseTransition
        currentTransition.animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        self.currentTransition = nil
    }

    private func closestState(
        for gesture: Gesture,
        in transition: Transition? = nil,
        except excludingState: FloatingSheetState? = nil
    ) -> FloatingSheetState? {
        guard let context = sheetView?.currentContext() else { return nil }

        let gravitationPoints = states
            .filter { $0.id != excludingState?.id }
            .map { state -> GravitationPoint in
                let frame = state.position.frame(context)
                let expectedCenter = anchorPoint(for: frame)

                let projectedCenter: CGPoint
                if let transition = transition {
                    projectedCenter = transition.projectedPosition(for: gesture)
                } else {
                    projectedCenter = gesture.projectedStopPoint()
                }

                let distance = projectedCenter.distance(to: expectedCenter)
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

    private func nextExpectedState(from currentState: FloatingSheetState, for gesture: Gesture) -> FloatingSheetState? {
        return nil
    }

    private func anchorPoint(for frame: CGRect) -> CGPoint {
        frame.origin
    }
}

extension FloatingSheetDraggingBehaviour {
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

extension FloatingSheetDraggingBehaviour: UIGestureRecognizerDelegate {
}
