//
//  AppsManager.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 16/07/2022.
//


import Foundation
import SwiftUI
import AppStoreConnect_Swift_SDK

class AppsManager: ObservableObject {
    
    @Published var loadingIcons = false
    @Published var foundApps: [AppStoreConnect_Swift_SDK.App] = []
    @Published var appsAndImages: [AppIdAndImage] = []
    @Published var foundReviews: [AppStoreConnect_Swift_SDK.CustomerReview] = []
    @Published var selectedApp: AppStoreConnect_Swift_SDK.App = AppStoreConnect_Swift_SDK.App(type: .apps, id: "Placeholder", links: .init(this: ""))
    
    @Published var selectedAppId: String? = "Placeholder"
    @Published var selectedPage: SettingsPage? = .home
    
    init() {
        Task {
            await getAppsTwan()
        }
    }
    
    func removeCachedIcons() {
        var temp: [AppIdAndImage] = []
        
        appsMatchedWithIcons.forEach { app in
            temp.append(AppIdAndImage(appId: app.appId))
        }
        
        appsMatchedWithIcons = temp
    }
    
    @MainActor
    func getAppsTwan() async {
        do {
            let provider = APIProvider(configuration: CredentialsManager.shared.configuration)
            
            let request = APIEndpoint
                .v1
                .apps
                .get(parameters: .init(
                    sort: [.bundleID],
                    fieldsApps: [.name, .bundleID, .customerReviews]
                ))
            let apps = try await provider.request(request).data
            
            self.foundApps = apps
            
            for app in apps {
                if !appsMatchedWithIcons.contains(where: { $0.appId == app.id } ) {
                    appsMatchedWithIcons.append(AppIdAndImage(appId: app.id))
                }
            }
            
            let imageURLs: [String] = appsMatchedWithIcons.compactMap { $0.iconURL }
            await getIcons()
        } catch {
            print(error.localizedDescription)
            let nsError = error as NSError
            print(nsError)
            print(nsError.domain)
            print(nsError.code)
        }   
    }
    
    func makeActive(app: AppStoreConnect_Swift_SDK.App) {
        self.selectedApp = app
    }
    
    @MainActor
    func getIcons() async {
        loadingIcons = true
        
        do {
            let provider = APIProvider(configuration: CredentialsManager.shared.configuration)
            
            for app in appsMatchedWithIcons {
                if app.iconURL == nil {
                    
                    let request = APIEndpoint
                        .v1
                        .apps
                        .id(app.appId)
                        .builds
                        .get(fieldsBuilds: [
                            .iconAssetToken,
                            .uploadedDate
                        ])
                        
                    let builds = try await provider.request(request).data
                    var newestBuildDate: Date?
                    
                    for build in builds {
                        guard let uploadDate = build.attributes?.uploadedDate else { continue }
                        
                        if newestBuildDate == nil {
                            newestBuildDate = uploadDate
                        } else {
                            if uploadDate > newestBuildDate! {
                                newestBuildDate = uploadDate
                            } else {
                                continue
                            }
                        }
                        
                        guard let url = build.attributes?.iconAssetToken?.templateURL else { continue }

                        if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.appId }) {
                            DispatchQueue.main.async(execute: {
                                let new = AppIdAndImage(appId: app.appId, iconURL: url)
                                self.appsMatchedWithIcons[firstIndex] = new
                            })
                        }
                        
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
            let nsError = error as NSError
            print(nsError)
            print(nsError.domain)
            print(nsError.code)
        }
                
        loadingIcons = false
    }
    
    @MainActor
    func getIconFor(app: AppStoreConnect_Swift_SDK.App) async {
        do {
            let provider = APIProvider(configuration: CredentialsManager.shared.configuration)
            
            let request = APIEndpoint
                .v1
                .apps
                .id(app.id)
                .builds
                .get(fieldsBuilds: [.uploadedDate], limit: 1)
            
            let builds = try await provider.request(request).data
//            for app in appsMatchedWithIcons {
//                if app.iconURL == nil {
//
//
//
//                    for build in builds {
//                        print(build.attributes?.iconAssetToken?.templateURL)
//                        print(build.attributes?.uploadedDate?.formatted())
//                    }
//                    for build in builds.prefix(1) {
//                        if let url = build.attributes?.iconAssetToken?.templateURL {
//                            if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.appId }) {
//                                DispatchQueue.main.async(execute: {
//                                    let new = AppIdAndImage(appId: app.appId, iconURL: url)
//                                    self.appsMatchedWithIcons[firstIndex] = new
//                                })
//                            }
//                        }
//                    }
//                }
//            }
        } catch {
            print(error.localizedDescription)
            let nsError = error as NSError
            print(nsError)
            print(nsError.domain)
            print(nsError.code)
        }
                
        loadingIcons = false
    }
    
    func imageURLfor(appId: String) -> URL? {
        if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == appId } ) {
            var imageURLRaw = appsMatchedWithIcons[firstIndex].iconURL ?? ""
            imageURLRaw = imageURLRaw
                .replacingOccurrences(of: "{w}", with: "32")
                .replacingOccurrences(of: "{h}", with: "32")
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
    
    func appNameFor(appId: String) -> String {
        if let app = foundApps.first(where: { $0.id == appId }) {
            return app.attributes?.name ?? ""
        } else{
            return ""
        }
    }
    
    
    
    func imageURL(for app: AppStoreConnect_Swift_SDK.App) -> URL? {
        
        if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.id } ) {
            var imageURLRaw = appsMatchedWithIcons[firstIndex].iconURL ?? ""
            imageURLRaw = imageURLRaw
                .replacingOccurrences(of: "{w}", with: "100")
                .replacingOccurrences(of: "{h}", with: "100")
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


extension AppStoreConnect_Swift_SDK.App: Equatable {
    public static func == (lhs: AppStoreConnect_Swift_SDK.App, rhs: AppStoreConnect_Swift_SDK.App) -> Bool {
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
