//
//  SupportLanding.swift
//  Vivid
//
//  Created by Jordi Bruin on 11/04/2022.
//

import SwiftUI

struct SupportLanding: View {
    var body: some View {
        VStack {
            header
            contactButton
//            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity)
//        .background(Color.vividBlueDark)
    }
    
    var image: some View {
        AsyncImage(url: URL(string: "https://www.getvivid.app/images/header.jpeg")) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 400)
        } placeholder: {
            Color.gray.opacity(0.1)
                .frame(height: 400)
        }
        .clipShape(Rectangle())
    }
    
    var header: some View {
        VStack {
            Text("Superstar Support")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .padding(20)
            
            Text("Superstar is in active development so expect to run into some bugs or missing features. If you're reading this I (Jordi) am probably travelling through Africa for a few weeks without my laptop, so bear with me here. Have a look at the list of known issues, and let me know if you found a bug that you think I should fix at jordi@goodsnooze.com!")
                .font(.system(.title2, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 80)
    }
    
    var contactButton: some View {
        Link(destination: URL(string: "mailto:jordi@goodsnooze.com")!) {
            Text("Email Support")
                .font(.system(.title2, design: .rounded))
                .bold()
                .padding(12)
                .padding(.horizontal, 8)
                .background(
                    ZStack {
                        Color.white
                        LinearGradient(colors: [.orange.opacity(0.7), .orange.opacity(0.9)], startPoint: .leading, endPoint: .trailing)
                    }
                )
                .cornerRadius(25)
                .foregroundColor(.white)
        }
    }
}

struct SupportLanding_Previews: PreviewProvider {
    static var previews: some View {
        SupportLanding()
    }
}
