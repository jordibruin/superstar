//
//  SuggestionsConfigView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import SwiftCSV
import AppStoreConnect_Swift_SDK

struct SuggestionsConfigView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    @AppStorage("hiddenAppIds") var hiddenAppIds: [String] = []
        
    @EnvironmentObject var appsManager: AppsManager
    
    @State private var selection: Suggestion.ID?
    
    @State var title = ""
    @State var text = ""
    
    @State var tableHovered = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                importButton
                exportButton
            }
            Table(suggestions, selection: $selection) {
                TableColumn("Title", value: \.title)
                    .width(min: 60, ideal: 80, max: 100)
                
                TableColumn("Text", value: \.text)
                    .width(min: 400, ideal: 450)
                    
                
                TableColumn("App") { suggestion in
                    HStack {
                        if let url = appsManager.imageURLfor(appId: "\(suggestion.appId)") {
                            CacheAsyncImage(url: url, scale: 2) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .clipped()
                                case .failure(let _):
                                    Text("E")
                                case .empty:
                                    Color.gray.opacity(0.05)
                                @unknown default:
                                    // AsyncImagePhase is not marked as @frozen.
                                    // We need to support new cases in the future.
                                    Image(systemName: "questionmark")
                                }
                            }
                            .frame(width: 15, height: 15)
                        }
                        
                        Text(appsManager.appNameFor(appId: "\(suggestion.appId)"))
                    }
                }
                .width(min: 60, ideal: 80, max: 100)
                
                TableColumn("") { suggestion in
                    Button {
                        print("Deleting")
                        if let firstIndex = suggestions.firstIndex(where: { suggestion.id == $0.id }) {
                            suggestions.remove(at: firstIndex)
                        } else {
                            print("no match found")
                        }
                        selection = nil
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash.fill")
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .width(30)
            }
            .frame(height: 400)
            .onDrop(of: [.fileURL], isTargeted: $tableHovered) { providers in
                handleExternalFileDrop(providers: providers)
            }
            .cornerRadius(8)
            
            
            
            if selection != nil {
                
                if let index = suggestions.firstIndex(where: { $0.id == selection }) {
                    VStack(alignment: .trailing) {
                        HStack(alignment: .top) {
                            TextField("Title", text: $suggestions[index].title)
                                .font(.title3)
                                .frame(width: 150)
                            
                            ZStack {
                                TextEditor(text: $suggestions[index].text)
                                    .font(.title3)
                                    .background(Color(.controlBackgroundColor))
                                    .frame(height: 80)
                                    .overlay(
                                        TextEditor(text: .constant("Response Text"))
                                            .font(.title3)
                                            .background(Color(.controlBackgroundColor))
                                            .opacity(0.4)
                                            .allowsHitTesting(false)
                                            .opacity(suggestions[index].text.isEmpty ? 1 : 0)
                                            .frame(height: 80)
                                    )
                            }
                            
                            Picker(selection: $suggestions[index].appId) {
                                Text("None")
                                    .tag(0)
                                
                                ForEach(appsManager.foundApps, id: \.id) { app in
                                    if !hiddenAppIds.contains(app.id) {
                                        Text(app.attributes?.name ?? "No Name")
                                            .tag(Int(app.id) ?? 0)
                                    }
                                }
                            } label: {
                                Text("Link to App")
                            }
                            .labelsHidden()
                            .frame(width: 180)
                            
                            
                        }
                        Button {
                            suggestions.remove(at: index)
                        } label: {
                            Text("Delete")
                        }
                        .keyboardShortcut(.delete, modifiers: [])
                    }
                }
            } else {
                HStack(alignment: .top) {
                    TextField("Title", text: $title)
                        .font(.title3)
                        .frame(width: 150)
                    
                    textEditors
                    
                    appDropdown
                    
                    Button {
                        suggestions.append(Suggestion(title: title, text: text, appId: Int(selectedApp) ?? 0))
                        title = ""
                        text = ""
                    } label: {
                        Text("Add")
                    }
                }
            }
        }
        .padding()
    }
    
    var importButton: some View {
        Button {
            importCSV()
        } label: {
            Text("Import")
        }
    }
    
    var exportButton: some View {
        Button {
            createCSV()
        } label: {
            Text("Export")
        }

    }
    
    func handleExternalFileDrop(providers: [NSItemProvider]) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                if let url = object {
                    importCSVFrom(url: url)
                }
            }
            return true
        }
        return false
    }
    
    func importCSVFrom(url: URL){
        do {
            let csvFile: CSV = try CSV<Named>(url: url)
            
            var newSuggestions: [Suggestion] = []
            
            for row in csvFile.rows {
                suggestions.append(Suggestion(csv: row))
            }
            self.suggestions.append(contentsOf: newSuggestions)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func importCSV() {
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            if let url = panel.url {
                importCSVFrom(url: url)
            }
        }
    }
    
    
    func createCSV() -> Void {
        let fileName = "Suggestions.csv"
//        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Title;Text;AppId;Id\n"
        
        for suggestion in suggestions {
            let newLine = "\(suggestion.title);\(suggestion.text);\(suggestion.appId);\(suggestion.id)\n"
            csvText.append(newLine)
        }
        
        do {
            let panel = NSSavePanel()
            panel.title = "Export Responses"
            panel.nameFieldStringValue = "Response Suggestions.csv"
            if panel.runModal() == .OK {
                if let url = panel.url {
                    try csvText.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                }
//                print(panel.url?.lastPathComponent ?? "<none>")
    //            self.filename = panel.url?.lastPathComponent ?? "<none>"
            }

        } catch {
            print("Failed to create file")
            print("\(error)")
        }
//        print(path ?? "not found")
    }
    
    var textEditors: some View {
        ZStack {
            TextEditor(text: $text)
                .font(.title3)
                .background(Color(.controlBackgroundColor))
                .frame(height: 80)
                .overlay(
                    TextEditor(text: .constant("Response Text"))
                        .font(.title3)
                        .background(Color(.controlBackgroundColor))
                        .opacity(0.4)
                        .allowsHitTesting(false)
                        .opacity(text.isEmpty ? 1 : 0)
                        .frame(height: 80)
                )
        }
    }
    
    var appDropdown: some View {
        Picker(selection: $selectedApp) {
            Text("None")
                .tag(0)
            
            ForEach(appsManager.foundApps, id: \.id) { app in
                if !hiddenAppIds.contains(app.id) {
                    Text(app.attributes?.name ?? "No Name")
                        .tag(app.id)
                }
            }
                
        } label: {
            Text("Link to App")
        }
        .labelsHidden()
        .frame(width: 140)
    }
    
    @State var selectedApp: String = "0"
}


//struct SuggestionsConfigView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuggestionsConfigView()
//    }
//}
