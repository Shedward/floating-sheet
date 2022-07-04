//
//  FloatingSheetScrollingBehaviour.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 04.07.2022.
//

import UIKit

final class FloatingSheetScrollingBehaviour: NSObject {

    weak var transitionBehaviour: FloatingSheetTransitionBehaviour?
    weak var view: FloatingSheetView?

    private(set) var isTransitioning: Bool = false

    private weak var floatingScrollView: UIScrollView?
    private var floatingScrollViewDelegate = UIScrollViewMultiDelegate()
    private var lastTransitionGesture: Gesture?
}

extension FloatingSheetScrollingBehaviour: UIScrollViewDelegate {

    func setFloatingScrollView(_ scrollView: UIScrollView?) {
        if
            let existingScrollView = floatingScrollView,
            existingScrollView.delegate === floatingScrollViewDelegate
        {
            existingScrollView.delegate = nil
        }

        floatingScrollView = scrollView

        if let scrollView = scrollView {
            floatingScrollViewDelegate = .init(delegates: [scrollView.delegate, self])
            scrollView.delegate = floatingScrollViewDelegate
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard
            let view = view,
            let transitionBehaviour = transitionBehaviour
        else {
            return
        }

        let scrollingGesture = view.gesture(for: scrollView.panGestureRecognizer)
        isTransitioning = shouldTransitioningInsteadOfScrolling(for: scrollingGesture)

        if isTransitioning {
            transitionBehaviour.didPan(state: .began, gesture: scrollingGesture)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            isTransitioning,
            let view = view,
            let transitionBehaviour = transitionBehaviour
        else { return }

        let scrollingGesture = view.gesture(for: scrollView.panGestureRecognizer)
        transitionBehaviour.didPan(state: .changed, gesture: scrollingGesture)

        var offset = scrollView.contentOffset
        offset.y = -scrollView.adjustedContentInset.top
        scrollView.setContentOffset(offset, animated: false)

        lastTransitionGesture = scrollingGesture
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isTransitioning {
            targetContentOffset.pointee = scrollView.contentOffset
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let lastTransitionGesture = lastTransitionGesture {
            transitionBehaviour?.didPan(state: .ended, gesture: lastTransitionGesture)
            self.lastTransitionGesture = nil
        }
        isTransitioning = false
    }

    private func shouldTransitioningInsteadOfScrolling(for gesture: Gesture) -> Bool {
        guard
            let scrollView = floatingScrollView,
            let transitionBehaviour = transitionBehaviour
        else { return false }

        if transitionBehaviour.isTransitioning {
            return true
        }

        if scrollView.contentOffset.y > -scrollView.adjustedContentInset.top {
            // If content is already scrolled we allow user to scroll back
            return false
        }

        return transitionBehaviour.haveTransition(for: gesture)
    }
}
