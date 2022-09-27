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


struct BigCTAButton: View {
    var action : () -> ()
    let title: LocalizedStringKey
    var icon = ""
    var isActive : Bool = true
    
    @State private var isHovering : Bool = false
    
    var textColor : Color {

        
        if isActive {
            return .white
        }
        
        return Color.primary
        
    }
    
    
    var backgroundColor : Color {
        
        if isHovering {
            if isActive {
                return Color.accentColor.opacity(0.8)
            }
        }
        
        if isActive {
            return Color.accentColor
        }
        
        return Color.primary.opacity(0.1)
    }
    
    @State private var offset = 0.0

    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 3) {
                if icon.isEmpty == false {
                    Image(systemName: icon)
                        .offset(x: 0, y: -offset)
                        .symbolRenderingMode(.hierarchical)
                    
                }
                Text(title)
            }
        }
        .buttonStyle(.plain)
        .controlSize(.large)
        .font(.system(.title3, design: .rounded).weight(.semibold))
        .foregroundColor(textColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .animation(.spring().repeatForever(autoreverses: true), value: offset)
        .onHover { hover in
            withAnimation(.easeIn(duration: 0.25)) {
                isHovering = hover
            }
            
            if isActive {
                offset = 3
            }
        }
        .onChange(of: isHovering) { _ in
            if !isHovering {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
    }
}
