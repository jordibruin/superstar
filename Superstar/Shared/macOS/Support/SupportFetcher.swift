//
//  SupportFetcher.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

/// The class that retrieves the json data either remotely or from a local file
class SupportFetcher: ObservableObject {
    
    @Published var faqSections: [FAQSection] = []
    @Published var allItems: [SupportItemable] = []
    
    @Published var retrievedSupport: Bool = false
    
    var session = URLSession.shared
    
    init() {
        loadAsync()
    }
    
    
    /// Load JSON data from external server
    func loadAsync() {
        let url = URL(string: "https://simplejsoncms.com/api/8q6uzcfbdl2")!
//        let url = URL(string: "https://simplejsoncms.com/api/1njq3x3lyry")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let error = error {
                print("Error with retrieving support: \(error.localizedDescription)")
                
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      
                      return
                  }
            
            guard let data = data else {
                return
            }

            do {
                let items = try JSONDecoder().decode(SupportItems.self, from: data)
                
                DispatchQueue.main.async(execute: {
                    self.faqSections = items.faqSections ?? []
                    self.retrievedSupport = true
                })
                
            } catch DecodingError.keyNotFound(let key, let context) {
                fatalError("Failed to decode  from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
            } catch DecodingError.typeMismatch(_, let context) {
                fatalError("Failed to decode  from bundle due to type mismatch – \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
                fatalError("Failed to decode  from bundle due to missing \(type) value – \(context.debugDescription)")
            } catch DecodingError.dataCorrupted(_) {
                fatalError("Failed to decode  from bundle because it appears to be invalid JSON")
            } catch {
                fatalError("Failed to decode  from bundle: \(error.localizedDescription)")
            }
        })
                
        task.resume()
    }
    
}
