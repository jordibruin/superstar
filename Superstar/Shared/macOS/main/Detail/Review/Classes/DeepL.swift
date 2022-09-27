//
//  DeepL.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI
import Combine

class DeepL: ObservableObject {
    @Published var sourceLanguages = [Language(name: "-", language: "-")]
    @Published var targetLanguages = [Language(name: "-", language: "-")]
    
    @Published var sourceLanguage: Language?
    @Published var targetLanguage: Language?
    
    @Published var detectedSourceLanguage: Language?
    
    @Published var sourceText = ""
    @Published var targetText = ""
    
    @Published var translatedTitle = ""
    @Published var translatedBody = ""
    @Published var translatedReply = ""
    
    @Published var formality = FormalityType.default;
    
    struct Language: Codable, Identifiable, Equatable {
        var id = UUID()
        let name: String
        let language: String
    }
    
    enum LanguagesType: String {
        case source
        case target
    }
    
    enum FormalityType: String {
        case `default`
        case more
        case less
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        print("init deepl")
        self.getLanguages(target: LanguagesType.source, handler: { languages, error in
            guard error == nil && languages != nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.sourceLanguages = languages!
                self.sourceLanguage = self.findLanguage(array: languages!, language: "EN")  // TODO: Default
            }
        })
        
        self.getLanguages(target: LanguagesType.target, handler: { languages, error in
            guard error == nil && languages != nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.targetLanguages = languages!
                self.targetLanguage = self.findLanguage(array: languages!, language: "NL") // TODO: Default
            }
        })
        
//        $sourceText
//            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
//            .sink(receiveValue: { value in
//                self.translate(text: value)
//            })
//            .store(in: &subscriptions)
    }
    
    private func getLanguages(target: LanguagesType, handler: @escaping ([Language]?, Error?) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-free.deepl.com"
        components.path = "/v2/languages"
        components.queryItems = [
            URLQueryItem(name: "auth_key", value: "cd8101dc-b9d7-acd9-f310-1cf89e8186de:fx"),
            URLQueryItem(name: "type", value: target.rawValue),
        ]
        
        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
            guard data != nil else {
                return
            }
            
            do {
                if let response = try JSONDecoder().decode([Language]?.self, from: data!) {
                    handler(response, nil)
                }
            } catch let error {
                handler(nil, error)
            }
        }).resume()
    }
    
    private func findLanguage(array: [Language], language: String) -> Language? {
        if let index = array.firstIndex(where: { $0.language == language }) {
            return array[index]
        }
        return nil
    }
    
    func translate(title: String, body: String) {
        translateTitle(text: title)
        translateBody(text: body)
    }
    
    func translateTitle(text: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-free.deepl.com"
        components.path = "/v2/translate"
        components.queryItems = [
            URLQueryItem(name: "auth_key", value: "cd8101dc-b9d7-acd9-f310-1cf89e8186de:fx"),
            // TODO: What is these are nil
//            URLQueryItem(name: "source_lang", value: "NL"), // TODO: Default
            URLQueryItem(name: "target_lang", value: "EN"), // TODO: Default
            URLQueryItem(name: "formality", value: self.formality.rawValue),
            URLQueryItem(name: "text", value: text)
        ]
        
        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
            guard data != nil else {
                return
            }
            
            struct Response: Codable {
                let translations: [Translation]
            }
            
            struct Translation: Codable {
                let detectedSourceLanguage: String?
                let text: String
                
                enum CodingKeys: String, CodingKey {
                    case detectedSourceLanguage = "detected_source_language"
                    case text
                }
            }
            
            if let response = try? JSONDecoder().decode(Response?.self, from: data!) {
                DispatchQueue.main.async {
                    if let language = response.translations[0].detectedSourceLanguage {
                        
                        if let foundLanguage = self.findLanguage(array: self.sourceLanguages, language: language) {
                            if foundLanguage.language != self.sourceLanguage!.language {
                                self.sourceLanguage = self.findLanguage(array: self.sourceLanguages, language: language) // TODO: Default
                            }
                        }
                    }
                    
                    self.translatedTitle = response.translations[0].text
                    
                }
            }
        }).resume()
    }
    
    func translateBody(text: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-free.deepl.com"
        components.path = "/v2/translate"
        components.queryItems = [
            URLQueryItem(name: "auth_key", value: "cd8101dc-b9d7-acd9-f310-1cf89e8186de:fx"),
            // TODO: What is these are nil
//            URLQueryItem(name: "source_lang", value: "NL"), // TODO: Default
            URLQueryItem(name: "target_lang", value: "EN"), // TODO: Default
            URLQueryItem(name: "formality", value: self.formality.rawValue),
            URLQueryItem(name: "text", value: text)
        ]
        
        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
            guard data != nil else {
                return
            }
            
            struct Response: Codable {
                let translations: [Translation]
            }
            
            struct Translation: Codable {
                let detectedSourceLanguage: String?
                let text: String
                
                enum CodingKeys: String, CodingKey {
                    case detectedSourceLanguage = "detected_source_language"
                    case text
                }
            }
            
            if let response = try? JSONDecoder().decode(Response?.self, from: data!) {
                DispatchQueue.main.async {
                    if let language = response.translations[0].detectedSourceLanguage {
                        if let foundLanguage = self.findLanguage(array: self.sourceLanguages, language: language) {
                            if foundLanguage.language != self.sourceLanguage!.language {
                                self.sourceLanguage = self.findLanguage(array: self.sourceLanguages, language: language) // TODO: Default
                            }
                            self.detectedSourceLanguage = foundLanguage
                            
                        }
                    }
                    
                    self.translatedBody = response.translations[0].text
                }
            }
        }).resume()
    }
    
    func translateReply(text: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-free.deepl.com"
        components.path = "/v2/translate"
        components.queryItems = [
            URLQueryItem(name: "auth_key", value: "cd8101dc-b9d7-acd9-f310-1cf89e8186de:fx"),
            // TODO: What is these are nil
//            URLQueryItem(name: "source_lang", value: "NL"), // TODO: Default
            URLQueryItem(name: "target_lang", value: detectedSourceLanguage?.language ?? "EN"), // TODO: Default
            URLQueryItem(name: "formality", value: self.formality.rawValue),
            URLQueryItem(name: "text", value: text)
        ]
        
        URLSession.shared.dataTask(with: components.url!, completionHandler: { data, _, _ in
            guard data != nil else {
                return
            }
            
            struct Response: Codable {
                let translations: [Translation]
            }
            
            struct Translation: Codable {
                let detectedSourceLanguage: String?
                let text: String
                
                enum CodingKeys: String, CodingKey {
                    case detectedSourceLanguage = "detected_source_language"
                    case text
                }
            }
            
            if let response = try? JSONDecoder().decode(Response?.self, from: data!) {
                DispatchQueue.main.async {
                    if let language = response.translations[0].detectedSourceLanguage {
                        if let foundLanguage = self.findLanguage(array: self.sourceLanguages, language: language) {
                            if foundLanguage.language != self.sourceLanguage!.language {
                                self.sourceLanguage = self.findLanguage(array: self.sourceLanguages, language: language) // TODO: Default
                            }
//                            self.detectedSourceLanguage = foundLanguage
                        }
                    }
                    
                    self.translatedReply = response.translations[0].text
                    print(response.translations[0].text)
                }
            }
        }).resume()
    }
}
