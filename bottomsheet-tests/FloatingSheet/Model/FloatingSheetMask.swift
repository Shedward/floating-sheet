//
//  FloatingSheetMask.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetMask {
    let mask: (_ context: FloatingSheetContext) -> CGRect?

    static func none() -> FloatingSheetMask {
        .init { _ in
            nil
        }
    }
}
