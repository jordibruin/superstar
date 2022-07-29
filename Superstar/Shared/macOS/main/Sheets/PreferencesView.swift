//
//  PreferencesView.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 27/07/2022.
//

import SwiftUI

struct PreferencesView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    
    @State var width: CGFloat = 400
    @State var height: CGFloat = 400
    
    @State var hoverClose = false
    var body: some View {
        TabView(selection: $settingsManager.selectedPage, content: {
            ForEach(SettingsPage.allCases) { page in
                page.destination
                    .tabItem {
                        page.label
                    }
                    .tag(page)
            }
        })
    }
}


struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
