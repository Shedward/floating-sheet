//
//  FloatingSheetViewController.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 27.06.2022.
//

import UIKit

final class FloatingSheetViewController: UIViewController {
    typealias ContentController = UIViewController & FloatingSheetPresentable

    private let contentView: FloatingSheetView = .init()
    private let contentController: ContentController

    init(contentController: ContentController) {
        self.contentController = contentController
        super.init(nibName: nil, bundle: nil)
        setContentController(contentController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    private func setContentController(_ controller: ContentController) {
        controller.willMove(toParent: self)
        contentView.setContent(controller.view)

        contentView.setStates(controller.floatingStates)
        if let initialState = controller.floatingStates.first {
            contentView.setCurrentState(initialState)
        }

        addChild(controller)
    }
}