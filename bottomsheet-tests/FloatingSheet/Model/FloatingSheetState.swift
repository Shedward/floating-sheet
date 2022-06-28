//
//  FloatingSheetState.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetState {
    let id: String
    var position: FloatingSheetPosition = .full()
    var mask: FloatingSheetMask = .none()
    var appearance: FloatingSheetAppearance = .init()
    var interaction: FloatingSheetInteractions = .init()
    var gravityCoefficient: CGFloat = 1.0

    init(id: String) {
        self.id = id
    }
}
