//
//  OpeningView.swift
//  Saikou Beta
//
//  Created by Inumaki on 06.03.23.
//

import SwiftUI
import WebKit

struct OpeningView: View {
    var animatedIcons: [UIImage]! = (0...29).map { UIImage(named: "LogoAnim-\($0)")! }
    @State var index: Int = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .default).autoconnect()
    @State var animationDone = false
    @State var navigate = false
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: Home(), isActive: $navigate) {
                Image(uiImage: self.animatedIcons[index])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 120)
                    .onReceive(timer) { (_) in
                        if(!animationDone) {
                            self.index = self.index + 1
                            if self.index == self.animatedIcons.count - 1 {
                                animationDone = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    navigate = true
                                }
                            }
                        }
                    }
            }
        }
        .accentColor(Color(hex: "#00000000"))
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
        .navigationBarBackButtonHidden(true)
    }
}

struct OpeningView_Previews: PreviewProvider {
    static var previews: some View {
        OpeningView()
    }
}
