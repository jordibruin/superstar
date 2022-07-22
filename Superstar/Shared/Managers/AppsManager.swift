//
//  AppsManager.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 16/07/2022.
//


import Foundation
import Bagbutik
import SwiftUI

class AppsManager: ObservableObject {
    
    @Published var loadingIcons = false
    @Published var foundApps: [Bagbutik.App] = []
    @Published var appsAndImages: [AppIdAndImage] = []
    @Published var foundReviews: [Bagbutik.CustomerReview] = []
    @Published var selectedApp: Bagbutik.App = Bagbutik.App(id: "Placeholder", links: ResourceLinks(self: ""))
    
    init() {
        Task {
            await getApps()
        }
    }
    
    func removeCachedIcons() {
        appsMatchedWithIcons.removeAll()
    }
    
    @MainActor
    func getApps() async {
        do {
            guard let jwt = CredentialsManager.shared.getJWT(), let service = try? BagbutikService(jwt: jwt) else { return }
            
            let response = try await service.request(
                .listAppsV1(
                    fields: [
                        .apps([
                            .bundleId,
                            .name,
                            .customerReviews
                        ])
                    ],
                    includes: [],
                    sorts: [.bundleIdAscending]
                )
            )
            self.foundApps = response.data
            
            
            // Add apps to the list for retrieving icons
            for app in response.data {
                if !appsMatchedWithIcons.contains(where: { $0.appId == app.id } ) {
                    appsMatchedWithIcons.append(AppIdAndImage(appId: app.id))
                }
            }
            
            let imageURLs: [String] = appsMatchedWithIcons.compactMap { $0.iconURL }
            
//            if imageURLs.isEmpty {
                // Never got icons yet
                // get the icons
                Task {
                    await getIcons()
                }
//            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func makeActive(app: Bagbutik.App) {
        self.selectedApp = app
    }
    
    @MainActor
    func getIcons() async {
        loadingIcons = true
        
        do {
            guard let jwt = CredentialsManager.shared.getJWT(), let service = try? BagbutikService(jwt: jwt) else { return }
            
            for app in appsMatchedWithIcons {
                if app.iconURL == nil {
//                    print("we don't have the icon for this boy yet, let's get it")
                    let response = try await service.request(
                        .listBuildsForAppV1(id: app.appId)
                    )
                    
                    for build in response.data.prefix(1) {
                        if let url = build.attributes?.iconAssetToken?.templateUrl {
                            if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.appId }) {
                                DispatchQueue.main.async(execute: {
                                    let new = AppIdAndImage(appId: app.appId, iconURL: url)
                                    self.appsMatchedWithIcons[firstIndex] = new
                                })
                            }
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
                
        loadingIcons = false
    }
    
    func imageURL(for app: Bagbutik.App) -> URL? {
        
        if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.id } ) {
            var imageURLRaw = appsMatchedWithIcons[firstIndex].iconURL ?? ""
            imageURLRaw = imageURLRaw
                .replacingOccurrences(of: "{w}", with: "200")
                .replacingOccurrences(of: "{h}", with: "200")
                .replacingOccurrences(of: "{f}", with: "png")

            if let url = URL(string: imageURLRaw) {
                return url
            } else {
                return nil
            }
        } else {
            return nil

        }
    }
    
    @AppStorage("appsMatchedWithIcons") var appsMatchedWithIcons: [AppIdAndImage] = []
}

struct AppIdAndImage: Codable {
    let appId: String
    var iconURL: String?
}

extension Bagbutik.App {
    func printApp() {
//        print(self.attributes?.name)
//        print(self.id)
    }
}

extension Bagbutik.App: Equatable {
    public static func == (lhs: Bagbutik.App, rhs: Bagbutik.App) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}


extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }
        do {
            let result = try JSONDecoder().decode([Element].self, from: data)
            self = result
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
