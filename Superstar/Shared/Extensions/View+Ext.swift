//
//  View+Ext.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func center( _ axis: Axis)-> some View {
        switch axis {
            case .horizontal:
                HStack {
                    Spacer()
                    self
                    Spacer()
                }
            case .vertical:
                VStack {
                    Spacer()
                    self
                    Spacer()
                }
        }
    }
    
    @ViewBuilder
    func place( _ axis: HorizontalAlignment)-> some View {
        switch axis {
            case .trailing:
                HStack {
                    Spacer()
                    self
                    
                }
            default:
                HStack {
                    self
                    Spacer()
                }
        }
    }
}

