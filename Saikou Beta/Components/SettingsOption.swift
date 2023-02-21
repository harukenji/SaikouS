//
//  SettingsOption.swift
//  Saikou Beta
//
//  Created by Inumaki on 20.02.23.
//

import SwiftUI
import SwiftUIFontIcon

struct SettingsOption: View {
    let setting_name: String
    let selected_option: String
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 20, maxHeight: 20)
                    .padding(.trailing, 12)
                
                Text("\(setting_name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(selected_option)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                FontIcon.button(.awesome5Solid(code: .chevron_right), action: {
                    Task {
                        
                    }
                    
                }, fontsize: 14)
                .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: .infinity, height: 40)
        .frame(maxWidth: .infinity, maxHeight: 40)
        .padding(.horizontal, 20)
    }
}

struct SettingsOption_Previews: PreviewProvider {
    static var previews: some View {
        SettingsOption(setting_name: "home", selected_option: "")
    }
}
