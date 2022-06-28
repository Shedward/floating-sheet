//
//  FloatingSheetPosition.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 28.06.2022.
//

import UIKit

struct FloatingSheetPosition {
    let frame: (_ context: FloatingSheetContext) -> CGRect

    static func custom(_ frame: @escaping (_ context: FloatingSheetContext) -> CGRect) -> FloatingSheetPosition {
        .init(frame: frame)
    }

    static func full() -> FloatingSheetPosition {
        .init { context in
            CGRect(origin: .zero, size: context.availableSize)
        }
    }

    static func relativeBottomHeight(_ relativeHeight: CGFloat) -> FloatingSheetPosition {
        .init { context in
            let heigth = context.availableSize.height * relativeHeight
            return FloatingSheetPosition.absoluteBottomHeight(heigth).frame(context)
        }
    }

    static func absoluteBottomHeight(_ absoluteHeight: CGFloat) -> FloatingSheetPosition {
        .init { context in
            CGRect(
                x: 0,
                y: context.availableSize.height - absoluteHeight,
                width: context.availableSize.width,
                height: absoluteHeight
            )
        }
    }

    func inseted(_ insets: UIEdgeInsets) -> FloatingSheetPosition {
        .init { context in
            self.frame(context).inset(by: insets)
        }
    }
}
