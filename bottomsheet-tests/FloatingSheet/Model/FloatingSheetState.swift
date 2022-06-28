//
//  FloatingSheetState.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetState {
    let id: String
    var position: FloatingSheetPosition
    var mask: FloatingSheetMask
    var appearance: FloatingSheetAppearance
    var gravityCoefficient: CGFloat

    init(
        id: String,
        position: FloatingSheetPosition = .full(),
        mask: FloatingSheetMask = .none(),
        appearance: FloatingSheetAppearance = .init(),
        gravityCoefficient: CGFloat = 1.0
    ) {
        self.id = id
        self.position = position
        self.mask = mask
        self.appearance = appearance
        self.gravityCoefficient = gravityCoefficient
    }
}
