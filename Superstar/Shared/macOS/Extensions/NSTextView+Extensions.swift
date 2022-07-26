//
//  NSTextView+Extensions.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 26/07/2022.
//

import Foundation

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}
