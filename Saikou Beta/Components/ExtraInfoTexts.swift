//
//  ExtraInfoTexts.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import SwiftUI

struct ExtraInfoTexts: View {
    let viewModel: InfoViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 8) {
                VStack(spacing: 8) {
                    HStack {
                        Text("Mean Score")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text(viewModel.infodata!.rating != nil ? String(format: "%.1f", Float(viewModel.infodata!.rating!) / 10) : "0.0")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(Color(hex: "#FF5DAE"))
                        + Text(" / 10")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Status")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text(viewModel.infodata!.status.uppercased())
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Total Episodes")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text(String(viewModel.infodata!.totalEpisodes ?? 0))
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Average Duration")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text(String(viewModel.infodata!.duration ?? 0) + " min")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Format")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text(viewModel.infodata!.type != nil ? viewModel.infodata!.type!.uppercased() : "Unknown")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
                VStack(spacing: 8) {
                    if(viewModel.infodata!.studios.count > 0) {
                        HStack {
                            Text("Studio")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer ()
                            
                            Text(viewModel.infodata!.studios[0])
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(Color(hex: "#FF5DAE"))
                        }
                    }
                    HStack {
                        Text("Season")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text((viewModel.infodata!.season ?? "UNKNOWN") +  " \(viewModel.infodata!.releaseDate)")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Start Date")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer ()
                        
                        Text(String(viewModel.infodata!.startDate.day ?? 0) + " " + (viewModel.infodata!.startDate.month != nil ? DateFormatter().monthSymbols[viewModel.infodata!.startDate.month! - 1] : "Unknown") + ", " + (viewModel.infodata!.startDate.year != nil ? String(viewModel.infodata!.startDate.year!) : "NaN"))
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    
                }
            }
            .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                if(viewModel.infodata!.title.native != nil) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name Native")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        Text("    " + viewModel.infodata!.title.native!)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
                if(viewModel.infodata!.title.english != nil) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name English")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        Text("    " + viewModel.infodata!.title.english!)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

struct ExtraInfoTexts_Previews: PreviewProvider {
    static var previews: some View {
        ExtraInfoTexts(viewModel: InfoViewModel())
    }
}
