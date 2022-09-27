//
//  SmallButton.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI

struct SmallButton: View {
    var action : () -> ()
    let title: LocalizedStringKey
    var icon = ""
    
    @State private var isHovering : Bool = false
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 3) {
                if icon.isEmpty == false {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .buttonStyle(.plain)
        .font(.system(.headline, design: .rounded).weight(.semibold))
        .foregroundColor(isHovering ? .primary : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isHovering ? Color.secondary.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .onHover { hover in
            withAnimation(.easeIn(duration: 0.25)) {
                isHovering = hover
            }
        }
    }
}
