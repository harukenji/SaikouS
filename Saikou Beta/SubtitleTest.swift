//
//  SubtitleTest.swift
//  Saikou Beta
//
//  Created by Inumaki on 06.03.23.
//

import SwiftUI

struct SubtitleTest: View {
    
    func fetchSubtitles(url: String) {
        
    }
    
    var body: some View {
        VStack {
            ZStack {
                Image("screenshot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct SubtitleTest_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleTest()
    }
}
