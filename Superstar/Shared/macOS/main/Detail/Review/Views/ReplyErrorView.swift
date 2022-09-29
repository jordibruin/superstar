//
//  ReplyErrorView.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI

struct ReplyErrorView: View {
    @Binding var error : NSError?
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .symbolRenderingMode(.hierarchical)
                .font(.system(.title, design: .rounded))
                .imageScale(.large)
            
            VStack(spacing: 8) {
                Text("Could not Send Reply")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .padding(.bottom, 4)
                Text("Double check that your App Store Connect credentials have the 'Admin' rights attached to it.")
                    .opacity(0.75)
                Text(error?.errorString ?? "")
                    .fontWeight(.semibold)
            }
            .padding()
            
            SmallButton(action: removeError, title: "Hide Error", helpText: "Remove the error alert")
            .padding(.bottom)
        }
        .multilineTextAlignment(.center)
        .font(.system(.body, design: .rounded).weight(.medium))
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .center(.horizontal)
    }
    
    private func removeError() {
        withAnimation {
            error = nil
        }
    }
}
