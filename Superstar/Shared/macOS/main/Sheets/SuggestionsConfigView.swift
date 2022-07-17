//
//  SuggestionsConfigView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI

struct SuggestionsConfigView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showSheet: Bool
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    
    @State private var selection: Suggestion.ID?

    @State var title = ""
    @State var text = ""
    
    var body: some View {
        

            
            VStack {
                Spacer()
                Table(suggestions, selection: $selection) {
                    TableColumn("Title", value: \.title)
                        .width(min: 100, ideal: 120, max: 150)
                    
                    TableColumn("Text", value: \.text)
                        .width(min: 400, ideal: 450, max: 500)
                
//                    TableColumn("App Id") { suggestion in
//                        Text("\(suggestion.appId)")
//                    }
//                    .width(min: 60, ideal: 70, max: 80)
                    
                    TableColumn("Delete") { suggestion in
                        Button {
                            if let firstIndex = suggestions.firstIndex(where: { suggestion.id == $0.id }) {
                                suggestions.remove(at: firstIndex)
                            }
                        } label: {
                            Image(systemName: "trash.fill")
                                .padding(.vertical, 4)
                        }
                    }
                    .width(60)
                }
                
                if selection != nil {
//                    HStack {
//                        TextField("Title", text: $suggestions[)
//                        TextField("Text", text: $text)
//    //                    Text("\(appId)")
//                        Button {
//                            suggestions.append(Suggestion(title: title, text: text, appId: Int(appId)!))
//                            title = ""
//                            text = ""
//                        } label: {
//                            Text("Add")
//                        }
//
//                    }
                } else {
                    HStack {
                        TextField("Title", text: $title)
                        TextField("Text", text: $text)
    //                    Text("\(appId)")
                        Button {
                            suggestions.append(Suggestion(title: title, text: text, appId: 0))
                            title = ""
                            text = ""
                        } label: {
                            Text("Add")
                        }

                    }
                }
                
                
                
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }

                }
            }
            .frame(width: 800, height: 500)
            .padding()
            .background(
                Color.gray.opacity(0.2)
            )
        
    }
}

//struct SuggestionsConfigView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuggestionsConfigView()
//    }
//}
