//
//  ProfileSelector.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//

import SwiftUI
import CoreData

// MARK: - FLEXIBLE VIEW

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

// MARK: - EXTENSION

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct profileData : Codable, Hashable {
    let image: String
    let profileName: String
}

struct ProfileSelector: View {
    
    @Environment(\.managedObjectContext) var moc
    
    let columns = [
        GridItem(.adaptive(minimum: 140), alignment: .center)
    ]
    
    let data = [
        profileData(image: "anime_pfp_boy_1", profileName: "Profile 1"),
        profileData(image: "anime_pfp_boy_2", profileName: "Profile 2"),
        profileData(image: "anime_pfp_girl_1", profileName: "Profile 3"),
    ]
    
    @Namespace var animation
    
    @State var showHome = false
    @State var selectedProfile: profileData = profileData(image: "anime_pfp_boy_1", profileName: "Profile 1")
    
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    Color(.black)
                    
                    VStack {
                        Text("Who is watching?")
                            .font(.system(size: 18, weight: .heavy))
                            .padding(.top, 100)
                        
                        Spacer()
                        
                        FlexibleView(
                            availableWidth: proxy.size.width, data: data,
                            spacing: 20,
                            alignment: .center
                        ) { profile in
                            
                            VStack {
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                        showHome = true
                                        selectedProfile = profile
                                    }
                                }) {
                                    Image(profile.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: 140, maxHeight: 140)
                                        .cornerRadius(24)
                                        .matchedGeometryEffect(id: profile.image, in: animation)
                                }
                                
                                Text(verbatim: profile.profileName)
                                    .foregroundColor(.white)
                            }
                            
                        }
                        .padding(.horizontal, 20)
                        
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Add new Profile")
                                .foregroundColor(Color(hex: "#FF5DAE"))
                                .font(.system(size: 18, weight: .heavy))
                                .padding(.vertical, 20)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: proxy.size.width - 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            Task {
                                let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = UserStorageInfo.fetchRequest()
                                let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
                                _ = try? moc.execute(batchDeleteRequest1)
                            }
                        }) {
                            ZStack {
                                Color(hex: "#D65050")
                                
                                HStack {
                                    Image("anilist")
                                        .resizable()
                                        .frame(maxWidth: 20, maxHeight: 15)
                                        .foregroundColor(Color(hex: "#ffc5e5"))
                                        .padding(.leading, 30)
                                    
                                    Text("Remove Stored Data")
                                        .fontWeight(.heavy)
                                        .foregroundColor(Color(hex: "#ffc5e5"))
                                        .padding(.vertical, 20)
                                        .padding(.trailing, 50)
                                        .padding(.leading, 30)
                                }
                            }
                            .cornerRadius(16)
                            .padding(.horizontal, 40)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 28)
                        }
                        .padding(.bottom, 60)
                    }
                }
                .overlay {
                    if(showHome) {
                        VStack {
                            Image(selectedProfile.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: 140, maxHeight: 140)
                                    .cornerRadius(24)
                            
                            Text(verbatim: selectedProfile.profileName)
                                .foregroundColor(.white)
                        }
                        .transition(.identity)
                        .onTapGesture {
                            showHome = false
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
        .navigationViewStyle(.stack)
    }
}

struct ProfileSelector_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSelector()
    }
}
