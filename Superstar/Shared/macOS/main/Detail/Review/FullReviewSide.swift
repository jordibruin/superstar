//
//  FullReviewSide.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct FullReviewSide: View {
    
    @Binding var review: CustomerReview?
    @FocusState private var isReplyFocused: Bool
    @StateObject private var translator = DeepL()
    @EnvironmentObject var reviewManager: ReviewManager
    @EnvironmentObject var appsManager: AppsManager
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    //<<<<<<< HEAD
    //    @State private var isReplying = false
    //    @State private var succesfullyReplied = false
    //=======
    @StateObject var credentials = CredentialsManager.shared
    
    @State var isReplying = false
    @State var succesfullyReplied = false
    
    
    @State private var error : NSError?  = nil
    
    @State private var replyText = ""
    @State private var hoveringOnSuggestion : Suggestion?
    @State private var showGoogleTranslate = false
    
    var translateString : String {
        "https://translate.google.com/?sl=auto&tl=en&text=\(review?.attributes?.title ?? "")\n\(review?.attributes?.body ?? "")&op=translate"
    }
    
    
    var hasReview : Bool {
        review != nil
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.gray.opacity(0.1)
            ScrollView {
                selectedReviewView
                
                if hasReview {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Reply View
                        ReviewReplyArea(isReplyFocused: $isReplyFocused,
                                        replyText: $replyText,
                                        hoveringOnSuggestion: $hoveringOnSuggestion,
                                        translator: translator)
                        
                        
                        BigCTAButton(action: {
                            Task {
                                await respondToReview()
                            }
                        }, title: "Send Reply", icon: "arrow.up.circle.fill", isActive: !replyText.isEmpty)
                        .disabled(replyText.isEmpty)
                        .help(Text("Send the response (⌘-Return)"))
                        .keyboardShortcut(.return, modifiers: .command)
                        .place(.trailing)
                        
                        if error != nil{
                            ReplyErrorView(error: $error)
                                .scaleEffect(error != nil ? 1 : 0)
                                .opacity(error != nil ? 1 : 0)
                        }
                        
                        Divider()
                        
                        ReviewSuggestionsPicker(replyText: $replyText, hoveringOnSuggestion: $hoveringOnSuggestion)
                        Spacer()
                    }
                    .padding()
                }
            }
            .clipped()
        }
        .frame(minWidth: 500)
        .overlay(
            ZStack {
                Color(.controlBackgroundColor)
                VStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 60))
                        .opacity(succesfullyReplied ? 1 : 0)
                        .animation(.default, value: isReplying)
                    
                    if isReplying {
                        ProgressView()
                    }
                    
                    Text(succesfullyReplied ? "Pending Publication" : "Sending Reply...")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
            }
                .opacity(isReplying || succesfullyReplied ? 1 : 0)
        )
        .onChange(of: review) { newValue in
            
            // Clean the translated strings
            translator.reset()
            
            //            reviewManager.replyText = ""
            isReplying = false
            succesfullyReplied = false
            replyText = ""
            isReplyFocused = true
        }
        
        .toolbar {
//            ToolbarItem(placement: .automatic) {
//                
//                // TODO: Not sure if you want this or not but it's not a bad practice
//                if hasReview {
//                    Button {
//                        if !translator.translatedTitle.isEmpty {
//                            translator.translatedBody = ""
//                            translator.translatedTitle = ""
//                        }
//                    } label: {
//                        Text("Show Original")
//                    }
//
//                    
//                } else {
//                    
//                }
//                    Button {
//                        if !translator.translatedTitle.isEmpty {
//                            translator.translatedBody = ""
//                            translator.translatedTitle = ""
//                        }
//                        } label: {
//                            Text("Show Original")
//                        }
//                    }
//                } else {
//                    Button {
//                        if credentials.deepLAPIKey.isEmpty {
//                            print("No translation key setup")
//                        } else {
//                            Task {
//                                await deepLReview()
//                            }
//                        }
//                    } label: {
//                        Image(systemName: "mail.and.text.magnifyingglass")
//                    }
//                    .help("Copy the review to your clipboard for sharing.")
//                }
//            
//            }
            
            ToolbarItem(placement: .automatic) {
                
                // TODO: Turn this in a "Share Review" feature
                if let review {
                    Button {
                        var ratingText = ""
                        let ratingCount = review.attributes?.rating ?? 1
                        for _ in (0..<ratingCount) {
                            ratingText.append("⭐️")
                        }
                        let reviewTitle = !translator.translatedTitle.isEmpty ? translator.translatedTitle : review.attributes?.title ?? ""
                        let reviewText = !translator.translatedBody.isEmpty ? translator.translatedBody : review.attributes?.body ?? ""
                        let pasteboard = NSPasteboard.general
                        pasteboard.declareTypes([.string], owner: nil)
                        pasteboard.setString("\(ratingText)\n\(reviewTitle)\n\(reviewText)", forType: .string)
                        
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .help("Copy the review to your clipboard for sharing.")
                }
            }
            
            
            ToolbarItem(placement: .automatic) {
                if let review {
                    SmallButton(action: {
                        print(review.attributes as Any)
                        print(review.links)
                        print(review.id)
                        // TODO: Mark review as done
                    }, title: "Mark as Done", icon: "checkmark.circle.fill", helpText: "Mark the review as done. Right now this does not do anything.")
                }
            }
        }
        
    }
    
    @ViewBuilder
    var selectedReviewView : some View {
        if let review {
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    ReviewRatingView(review: review)
                    Spacer()
                    
                    ReviewMetadata(review: review)
                        .font(.system(.headline, design: .rounded).weight(.medium))
                    Text("·")
                    if let creationDate = review.attributes?.createdDate {
                        Text(creationDate, style: .date)
                            .opacity(0.8)
                            .font(.system(.headline, design: .rounded).weight(.medium).smallCaps())
                    }
                }
                .padding([.horizontal, .top])
                
                VStack(alignment: .leading) {
                    ReviewTitle(translator: translator, review: review)
                    Text(!translator.translatedBody.isEmpty ? translator.translatedBody : review.attributes?.body ?? "")
                        .font(.system(.title3, design: .rounded))
                        .textSelection(.enabled)
                }
                .padding([.horizontal, .bottom])
                
                HStack {
                    
                    SmallButton(action: {
                        if !translator.translatedTitle.isEmpty {
                            translator.translatedBody = ""
                            translator.translatedTitle = ""
                        } else {
                            Task {
                                await deepLReview()
                            }
                        }
                    }, title: translator.translatedTitle.isEmpty ? "Translate Review" : "Show Original", helpText: translator.translatedTitle.isEmpty ? "Translate the review into English" : "Show the review in its original language")
                    
                    
                    if translator.detectedSourceLanguage != nil {
                        Text(translator.detectedSourceLanguage?.name ?? "No language found")
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    SmallButton(action: toggleGoogleTranslate,
                                title: showGoogleTranslate ? "Close" : "View Google Translate",
                                icon: showGoogleTranslate ? "xmark" : "globe",
                                helpText: showGoogleTranslate ? "Close the Google Translate Window" : "Translate review with Google Translate")
                }
                .buttonStyle(.plain)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.secondary)
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                
                
                if showGoogleTranslate {
                    WebView(urlString: translateString)
                        .frame(height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding()
        }
    }
    
    private func toggleGoogleTranslate() {
        withAnimation {
            showGoogleTranslate.toggle()
        }
    }
    
    private func getNewReview() {
        guard let review = review else {
            return
        }
        
        guard reviewManager.retrievedReviews.firstIndex(of: review) != nil else {
            return
        }
        
        if let review = reviewManager.retrievedReviews.filter({ !pendingPublications.contains($0.id ) }).randomElement() {
            self.review = review
        } else {
            print("No new reviews available")
        }
    }
    
    private func deepLReview() async {
        translator.translate(
            title: review?.attributes?.title ?? "No title",
            body: review?.attributes?.body ?? "No body"
        )
    }
    
    private func respondToReview() async {
        guard let review = review else { return }
        
        Task {
            withAnimation {
                isReplying = true
            }
            
            do {
                let replied = try await reviewManager.replyTo(review: review, with: replyText)
                
                isReplying = false
                if replied {
                    print("replied succesfully")
                    succesfullyReplied = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.getNewReview()
                    }
                } else {
                    print("could not reply")
                    succesfullyReplied = false
                }
            } catch {
                print(error.localizedDescription)
                let errorCode = (error as NSError).description
                print(errorCode)
                withAnimation(.spring()) {
                    self.error = (error as NSError)
                }
                isReplying = false
            }
            
        }
    }
    
}




//<<<<<<< HEAD
extension NSError {
    var errorString : String {
        if self.description.contains("This request is forbidden for security reasons") {
            return "This request is forbidden for security reasons"
        } else {
            return "Could not send reply. Not sure why, sorry!"
        }
    }
}

//=======
//struct WebViewWrapper: NSViewRepresentable {
//
//    let urlString: String
//
//    func makeNSView(context: Context) -> WKWebView {
//        return WKWebView()
//    }
//
//    func updateNSView(_ nsView: WKWebView, context: Context) {
//        //        var newURL = urlString
//
//        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            if let url = URL(string: encoded) {
//                let request = URLRequest(url: url)
//                nsView.load(request)
//            }
//        }
//    }
//}

//import Combine
//
//class DeepL: ObservableObject {
//    @Published var sourceLanguages = [Language(name: "-", language: "-")]
//    @Published var targetLanguages = [Language(name: "-", language: "-")]
//
//    @Published var sourceLanguage: Language?
//    @Published var targetLanguage: Language?
//
//    @Published var detectedSourceLanguage: Language?
//
//    @Published var sourceText = ""
//    @Published var targetText = ""
//
//    @Published var translatedTitle = ""
//    @Published var translatedBody = ""
//    @Published var translatedReply = ""
//
//    @Published var formality = FormalityType.default;
//
//    let key = CredentialsManager.shared.deepLAPIKey
//
//    struct Language: Codable, Identifiable, Equatable {
//        let id = UUID()
//        let name: String
//        let language: String
//    }
//
//    enum LanguagesType: String {
//        case source
//        case target
//    }
//
//    enum FormalityType: String {
//        case `default`
//        case more
//        case less
//    }
//
//    private var subscriptions = Set<AnyCancellable>()
//
//    init() {
//        print("init deepl")
//        self.getLanguages(target: LanguagesType.source, handler: { languages, error in
//            guard error == nil && languages != nil else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.sourceLanguages = languages!
//                self.sourceLanguage = self.findLanguage(array: languages!, language: "EN")  // TODO: Default
//            }
//        })
//
//        self.getLanguages(target: LanguagesType.target, handler: { languages, error in
//            guard error == nil && languages != nil else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.targetLanguages = languages!
//                self.targetLanguage = self.findLanguage(array: languages!, language: "NL") // TODO: Default
//            }
//        })
//
////        $sourceText
////            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
////            .sink(receiveValue: { value in
////                self.translate(text: value)
////            })
////            .store(in: &subscriptions)
//    }
//
//    private func getLanguages(target: LanguagesType, handler: @escaping ([Language]?, Error?) -> Void) {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api-free.deepl.com"
//        components.path = "/v2/languages"
//        components.queryItems = [
//            URLQueryItem(name: "auth_key", value: key),
//            URLQueryItem(name: "type", value: target.rawValue),
//        ]
//
//        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
//            guard data != nil else {
//                return
//            }
//
//            do {
//                if let response = try JSONDecoder().decode([Language]?.self, from: data!) {
//                    handler(response, nil)
//                }
//            } catch let error {
//                handler(nil, error)
//            }
//        }).resume()
//    }
//
//    private func findLanguage(array: [Language], language: String) -> Language? {
//        if let index = array.firstIndex(where: { $0.language == language }) {
//            return array[index]
//        }
//        return nil
//    }
//
//    func translate(title: String, body: String) {
//        translateTitle(text: title)
//        translateBody(text: body)
//    }
//
//    func translateTitle(text: String) {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api-free.deepl.com"
//        components.path = "/v2/translate"
//        components.queryItems = [
//            URLQueryItem(name: "auth_key", value: key),
//            // TODO: What is these are nil
////            URLQueryItem(name: "source_lang", value: "NL"), // TODO: Default
//            URLQueryItem(name: "target_lang", value: "EN"), // TODO: Default
//            URLQueryItem(name: "formality", value: self.formality.rawValue),
//            URLQueryItem(name: "text", value: text)
//        ]
//
//        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
//            guard data != nil else {
//                return
//            }
//
//            struct Response: Codable {
//                let translations: [Translation]
//            }
//
//            struct Translation: Codable {
//                let detectedSourceLanguage: String?
//                let text: String
//
//                enum CodingKeys: String, CodingKey {
//                    case detectedSourceLanguage = "detected_source_language"
//                    case text
//                }
//            }
//
//            if let response = try? JSONDecoder().decode(Response?.self, from: data!) {
//                DispatchQueue.main.async {
//                    if let language = response.translations[0].detectedSourceLanguage {
//
//                        if let foundLanguage = self.findLanguage(array: self.sourceLanguages, language: language) {
//                            if foundLanguage.language != self.sourceLanguage!.language {
//                                self.sourceLanguage = self.findLanguage(array: self.sourceLanguages, language: language) // TODO: Default
//                            }
//                        }
//                    }
//
//                    self.translatedTitle = response.translations[0].text
//
//                }
//            }
//        }).resume()
//    }
//
//    func translateBody(text: String) {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api-free.deepl.com"
//        components.path = "/v2/translate"
//        components.queryItems = [
//            URLQueryItem(name: "auth_key", value: key),
//            // TODO: What is these are nil
////            URLQueryItem(name: "source_lang", value: "NL"), // TODO: Default
//            URLQueryItem(name: "target_lang", value: "EN"), // TODO: Default
//            URLQueryItem(name: "formality", value: self.formality.rawValue),
//            URLQueryItem(name: "text", value: text)
//        ]
//
//        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
//            guard data != nil else {
//                return
//            }
//
//            struct Response: Codable {
//                let translations: [Translation]
//            }
//
//            struct Translation: Codable {
//                let detectedSourceLanguage: String?
//                let text: String
//
//                enum CodingKeys: String, CodingKey {
//                    case detectedSourceLanguage = "detected_source_language"
//                    case text
//                }
//            }
//
//            if let response = try? JSONDecoder().decode(Response?.self, from: data!) {
//                DispatchQueue.main.async {
//                    if let language = response.translations[0].detectedSourceLanguage {
//                        if let foundLanguage = self.findLanguage(array: self.sourceLanguages, language: language) {
//                            if foundLanguage.language != self.sourceLanguage!.language {
//                                self.sourceLanguage = self.findLanguage(array: self.sourceLanguages, language: language) // TODO: Default
//                            }
//                            self.detectedSourceLanguage = foundLanguage
//
//                        }
//                    }
//
//                    self.translatedBody = response.translations[0].text
//                }
//            }
//        }).resume()
//    }
//
//    func translateReply(text: String) {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api-free.deepl.com"
//        components.path = "/v2/translate"
//        components.queryItems = [
//            URLQueryItem(name: "auth_key", value: key),
//            // TODO: What is these are nil
////            URLQueryItem(name: "source_lang", value: "NL"), // TODO: Default
//            URLQueryItem(name: "target_lang", value: detectedSourceLanguage?.language ?? "EN"), // TODO: Default
//            URLQueryItem(name: "formality", value: self.formality.rawValue),
//            URLQueryItem(name: "text", value: text)
//        ]
//
//        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
//            guard data != nil else {
//                return
//            }
//
//            struct Response: Codable {
//                let translations: [Translation]
//            }
//
//            struct Translation: Codable {
//                let detectedSourceLanguage: String?
//                let text: String
//
//                enum CodingKeys: String, CodingKey {
//                    case detectedSourceLanguage = "detected_source_language"
//                    case text
//                }
//            }
//
//            if let response = try? JSONDecoder().decode(Response?.self, from: data!) {
//                DispatchQueue.main.async {
//                    if let language = response.translations[0].detectedSourceLanguage {
//                        if let foundLanguage = self.findLanguage(array: self.sourceLanguages, language: language) {
//                            if foundLanguage.language != self.sourceLanguage!.language {
//                                self.sourceLanguage = self.findLanguage(array: self.sourceLanguages, language: language) // TODO: Default
//                            }
////                            self.detectedSourceLanguage = foundLanguage
//                        }
//                    }
//
//                    self.translatedReply = response.translations[0].text
//                    print(response.translations[0].text)
//                }
//            }
//        }).resume()
////>>>>>>> main
//    }
//}
