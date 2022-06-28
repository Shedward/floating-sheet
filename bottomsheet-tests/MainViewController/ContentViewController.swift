//
//  ContentViewController.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

final class ContentViewController: UIViewController {

    private let fullState = FloatingSheetState(id: "full", position: .full())
    private let shrinkenState = FloatingSheetState(id: "shrinken", position: .absoluteBottomHeight(100))

    static func create() -> ContentViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: ContentViewController = storyboard.instantiateViewController(identifier: "ContentViewController")
        return viewController
    }
}

extension ContentViewController: FloatingSheetPresentable {
    var floatingStates: [FloatingSheetState] {
        [shrinkenState, fullState]
    }
}
