//
//  Gesture.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 30.06.2022.
//

import UIKit
import simd

struct Gesture {
    var center: CGPoint
    var velocity: CGPoint

    func projectedStopPoint() -> CGPoint {
        let acceleration: CGFloat = -900
        let accelerationVector = CGPoint(
            x: acceleration * sign(velocity.x),
            y: acceleration * sign(velocity.y)
        )

        let projectedPoint = CGPoint(
            x: center.x - 0.5 * velocity.x * velocity.x / accelerationVector.x,
            y: center.y - 0.5 * velocity.y * velocity.y / accelerationVector.y
        )

        return projectedPoint
    }
}
