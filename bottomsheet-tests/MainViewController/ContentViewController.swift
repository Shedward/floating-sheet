//
//  ContentViewController.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

final class ContentViewController: UIViewController {
    weak var floatingSheetController: FloatingSheetViewController?

    private let fullState = FloatingSheetState(id: "full", position: .full())
    private var shrinkenState = FloatingSheetState(
        id: "shrinken",
        position: .relativeBottomHeight(0.25, extendBottom: true)
            .inseted(.init(top: 16, left: 16, bottom: 16, right: 16))
    )

    static func create() -> ContentViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: ContentViewController = storyboard.instantiateViewController(identifier: "ContentViewController")
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shrinkenState.appearance.overlayColor = UIColor.black.withAlphaComponent(0.2)
        shrinkenState.appearance.cornerRadius = 24
    }

    @IBAction
    func switchToFull() {
        floatingSheetController?.setState(fullState, animated: true)
    }

    @IBAction
    func switchToShrink() {
        floatingSheetController?.setState(shrinkenState, animated: true)
    }
}

extension ContentViewController: FloatingSheetPresentable {
    var floatingStates: [FloatingSheetState] {
        [shrinkenState, fullState]
    }
}
