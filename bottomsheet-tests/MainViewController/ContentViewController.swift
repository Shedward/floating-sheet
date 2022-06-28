//
//  ContentViewController.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

final class ContentViewController: UIViewController {
    weak var floatingSheetController: FloatingSheetViewController?

    private var fullState = FloatingSheetState(id: "full")
    private var mediumState = FloatingSheetState(id: "medium")
    private var minimalState = FloatingSheetState(id: "minimal")

    @IBOutlet
    private var stackView: UIStackView!

    static func create() -> ContentViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: ContentViewController = storyboard.instantiateViewController(identifier: "ContentViewController")
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fullState.position = .full()

        mediumState.position = .relativeBottomHeight(0.5, extendBottom: true)
            .inseted(.init(top: 8, left: 8, bottom: 8, right: 8))
        mediumState.appearance.overlayColor = UIColor.black.withAlphaComponent(0.2)
        mediumState.appearance.cornerRadius = 24

        minimalState.position = .relativeBottomHeight(0.25, extendBottom: true)
            .inseted(.init(top: 16, left: 16, bottom: 16, right: 16))
        minimalState.mask = .aroundView(stackView)
            .inseted(.init(top: -4, left: -4, bottom: -4, right: -4))
        minimalState.appearance.cornerRadius = 8
    }

    @IBAction
    func switchToFull() {
        floatingSheetController?.setState(fullState, animated: true)
    }

    @IBAction
    func switchToShrink() {
        floatingSheetController?.setState(mediumState, animated: true)
    }

    @IBAction
    func switchToMinimal() {
        floatingSheetController?.setState(minimalState, animated: true)
    }
}

extension ContentViewController: FloatingSheetPresentable {
    var floatingStates: [FloatingSheetState] {
        [minimalState, mediumState, fullState]
    }
}
