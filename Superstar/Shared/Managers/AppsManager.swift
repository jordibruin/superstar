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
    
    @Published var foundApps: [Bagbutik.App] = []
    
    @Published var appsAndImages: [AppIdAndImage] = []
    
    @Published var foundReviews: [Bagbutik.CustomerReview] = []
    
    @Published var selectedApp: Bagbutik.App = Bagbutik.App(id: "Placeholder", links: ResourceLinks(self: ""))
    
    init() {
        Task {
            await getApps()
        }
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
            
//            appsMatchedWithIcons = []
            
            print("apps matched with icons count \(appsMatchedWithIcons.count))")
            
            for app in response.data {
                if !appsMatchedWithIcons.contains(where: { $0.appId == app.id } ) {
                    appsMatchedWithIcons.append(AppIdAndImage(appId: app.id))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func getIcons() async {
        
        
        do {
            let service = try BagbutikService(jwt: .init(
                keyId: "5RV9L7HM7W",
                issuerId: "69a6de8a-5b4e-47e3-e053-5b8c7c11a4d1",
                privateKey: """
        -----BEGIN PRIVATE KEY-----
        MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg41hQQir9NtMHfUq8
        zuUdNqMF93khEMirjynoLCeL7i2gCgYIKoZIzj0DAQehRANCAASBxdmD6ALMVKd0
        6/gzSl6q9Z4/5AsD0GdQGK/Fk+RryOjjvS0ibtwP4XZu4xRa/OwFkjWs85WQKux/
        +wwQpe21
        -----END PRIVATE KEY-----
        """
            ))
            
            for app in appsMatchedWithIcons {
                if app.iconURL == nil {
                    print("we don't have the icon for this boy yet, let's get it")
                    let response = try await service.request(
                        .listBuildsForAppV1(id: app.appId)
                    )
                    
                    for build in response.data.suffix(1) {
                        print("build found")
                        if let url = build.attributes?.iconAssetToken?.templateUrl {
                            
                            if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.appId }) {
                                print("found app in array so we can add the image to it")
                                DispatchQueue.main.async(execute: {
                                    
                                    let new = AppIdAndImage(appId: app.appId, iconURL: url)
                                    
                                    self.appsMatchedWithIcons[firstIndex] = new
//                                    print(self.appsMatchedWithIcons[firstIndex].iconURL)
                                    
                                })
                            }
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        print("we're done with stuff")
        print("apps matched with icons count \(appsMatchedWithIcons.count))")
    }
    
    func imageURL(for app: Bagbutik.App) -> URL {
        
        if let firstIndex = appsMatchedWithIcons.firstIndex(where: { $0.appId == app.id } ) {
            var imageURLRaw = appsMatchedWithIcons[firstIndex].iconURL ?? ""
            imageURLRaw = imageURLRaw
                .replacingOccurrences(of: "{w}", with: "200")
                .replacingOccurrences(of: "{h}", with: "200")
                .replacingOccurrences(of: "{f}", with: "png")

            if let url = URL(string: imageURLRaw) {
                return url
            } else {
                return URL(string: "https://cdn.dribbble.com/users/361233/screenshots/14417969/media/f3555d1770897661fe5e4a049a000606.jpg?compress=1&resize=200x200&vertical=top")!
            }
//            return appsMatchedWithIcons[firstIndex].iconURL
        } else {
            return URL(string: "https://cdn.dribbble.com/users/361233/screenshots/14417969/media/f3555d1770897661fe5e4a049a000606.jpg?compress=1&resize=200x200&vertical=top")!

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