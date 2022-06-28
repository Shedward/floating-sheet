//
//  FloatingSheetPresentable.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 27.06.2022.
//

import UIKit

protocol FloatingSheetPresentable: AnyObject {

    var floatingSheetController: FloatingSheetViewController? { get set }
    var floatingStates: [FloatingSheetState] { get }

    func didTapOverlay()
}

extension FloatingSheetPresentable {
    func didTapOverlay() {
    }
}
