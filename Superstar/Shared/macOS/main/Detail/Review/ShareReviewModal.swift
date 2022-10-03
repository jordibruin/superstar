//
//  ShareReviewModal.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 29/09/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ShareReviewModal: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var shareBGColor: Color = .green
    
    @State var sharePadding: CGFloat = 50
    
    let review: CustomerReview
    let title: String
    let bodyText: String
    
    var body: some View {
        VStack {
            ZStack {
                shareBackground
                shareReviewView
                    .padding(sharePadding)
            }
            .frame(height: 300)
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
                
                ColorPicker(selection: $shareBGColor, supportsOpacity: false) {
                    Text("Background Color")
                }
                .labelsHidden()
                
                Stepper(value: $sharePadding) {
                    Text("Review padding")
                }
                
                Spacer()
                saveButton
            }
            .padding()
        }
        .frame(width: 500)
    }
    
    
    var saveButton: some View {
        Button {
            let contentRect = NSRect(x: 0, y: 0, width: 400, height: 300)
            let imageWindow = NSWindow(
                contentRect: contentRect,
                styleMask: [.miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            
            imageWindow.contentView = NSHostingView(rootView:
                                                        ZStack {
                shareBackground
                shareReviewView
                    .padding(sharePadding)
            }
                .frame(height: 300)
            )
            
            let imageWindowRect = imageWindow.contentView!.bitmapImageRepForCachingDisplay(in: contentRect)!
            
            imageWindow.contentView!.cacheDisplay(in: contentRect, to: imageWindowRect)
            
            let image = NSImage(size: imageWindowRect.size)
            print(image)
            image.addRepresentation(imageWindowRect)
            
            //                        let data = NSData(contentsOfFile: <#T##String#>)
            
            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
            
            
            let destinationURL = desktopURL.appendingPathComponent("my-image.png")
            
            if image.pngWrite(to: destinationURL, options: .noFileProtection) {
                print("File saved")
            }
            
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([image])
            //                        showShareModal = false
        } label: {
            Text("Copy")
        }
    }
    
    var shareBackground: some View {
        LinearGradient(colors: [shareBGColor, shareBGColor.darker()], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    @ViewBuilder
    var shareReviewView : some View {
        
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
                Text(title)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .textSelection(.enabled)
                
                Text(bodyText)
                    .font(.system(.title3, design: .rounded))
                    .textSelection(.enabled)
            }
            .padding([.horizontal, .bottom])
            
            HStack {
                Spacer()
                SmallButton(action: {},
                            title: "Made with Superstar",
                            icon: "",
                            helpText: "")
            }
            .buttonStyle(.plain)
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding()
    }
    
    
}
//
//struct ShareReviewModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ShareReviewModal(title: "Title", bodyText: "Body")
//    }
//}
