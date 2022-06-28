//
//  FloatingSheetState.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetContext {
    let availableSize: CGSize
    let contentView: UIView
}

struct FloatingSheetState {
    let id: String
    var position: FloatingSheetPosition
    var mask: FloatingSheetMask
    var appearance: FloatingSheetAppearance

    init(
        id: String,
        position: FloatingSheetPosition,
        mask: FloatingSheetMask = .none(),
        appearance: FloatingSheetAppearance = .init()
    ) {
        self.id = id
        self.position = position
        self.mask = mask
        self.appearance = appearance
    }
}
