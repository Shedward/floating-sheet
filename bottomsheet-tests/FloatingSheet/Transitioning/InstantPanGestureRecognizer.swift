//
//  InstantPanGestureRecognizer.swift
//  bottomsheet-tests
//
//  Created by Vladislav Maltsev on 30.06.2022.
//

import UIKit

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard state != .began else { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
