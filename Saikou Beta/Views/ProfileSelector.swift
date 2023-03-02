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
    let id: String
    let image: String
    let profileName: String
}

struct ScrollingHStackModifier: ViewModifier {
    
    @State private var scrollOffset: CGFloat
    @State private var dragOffset: CGFloat
    
    var items: Int
    var itemWidth: CGFloat
    var itemSpacing: CGFloat
    
    init(items: Int, itemWidth: CGFloat, itemSpacing: CGFloat) {
        self.items = items
        self.itemWidth = itemWidth
        self.itemSpacing = itemSpacing
        
        // Calculate Total Content Width
        let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
        let screenWidth = UIScreen.main.bounds.width
        
        // Set Initial Offset to first Item
        let initialOffset = (contentWidth/2.0) - (screenWidth/2.0) + ((screenWidth - itemWidth) / 2.0)
        
        self._scrollOffset = State(initialValue: initialOffset)
        self._dragOffset = State(initialValue: 0)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: scrollOffset + dragOffset, y: 0)
            .gesture(DragGesture()
                .onChanged({ event in
                    dragOffset = event.translation.width
                })
                    .onEnded({ event in
                        // Scroll to where user dragged
                        scrollOffset += event.translation.width
                        dragOffset = 0
                        
                        // Now calculate which item to snap to
                        let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
                        let screenWidth = UIScreen.main.bounds.width
                        
                        // Center position of current offset
                        let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
                        
                        // Calculate which item we are closest to using the defined size
                        var index = (center - (screenWidth / 2.0)) / (itemWidth + itemSpacing)
                        
                        // Should we stay at current index or are we closer to the next item...
                        if index.remainder(dividingBy: 1) > 0.5 {
                            index += 1
                        } else {
                            index = CGFloat(Int(index))
                        }
                        
                        // Protect from scrolling out of bounds
                        index = min(index, CGFloat(items) - 1)
                        index = max(index, 0)
                        
                        // Set final offset (snapping to item)
                        let newOffset = index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
                        
                        // Animate snapping
                        withAnimation {
                            scrollOffset = newOffset
                        }
                        
                    })
            )
    }
}

struct ProfileSelector: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var selectedItem = 1
    
    let data = [
        profileData(id: "1",image: "anime_pfp_boy_1", profileName: "Profile 1"),
        profileData(id: "2",image: "anime_pfp_boy_2", profileName: "Profile 2"),
        profileData(id: "3",image: "anime_pfp_girl_1", profileName: "Profile 3"),
    ]
    
    @Namespace var animation
    
    @State var showHome = false
    @State var selectedProfile: profileData?
    
    
    var body: some View {
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
                        Button {
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                showHome = true
                                selectedProfile = profile
                            }
                        } label: {
                            ProfileCard(profile: profile)
                                .scaleEffect(selectedProfile?.id == profile.id && showHome ? 0.3 : 1)
                        }
                        .buttonStyle(ScaledButtonStyle())
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
                if let selectedProfile = selectedProfile, showHome {
                    HomeView(profile: selectedProfile)
                    
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func ProfileCard(profile: profileData) -> some View {
        VStack {
            Image(profile.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 140, maxHeight: 140)
                .cornerRadius(24)
            
            Text(verbatim: profile.profileName)
                .foregroundColor(.white)
        }
        .matchedGeometryEffect(id: profile.id, in: animation)
    }
    
    func HomeView(profile: profileData) -> some View {
        GeometryReader {proxy in
            ZStack {
                Color(.black)
                    .opacity(selectedProfile?.id == profile.id && showHome ? 1.0 : 0.0)
                    .animation(.easeInOut, value: selectedProfile?.id == profile.id && showHome)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            HStack {
                                Text("Inumaki")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(.leading, 20)
                                
                                Spacer()
                                
                                ProfileCard(profile: profile)
                                    .scaleEffect(selectedProfile?.id == profile.id && showHome ? 0.3 : 1)
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.top, 20)
                    }
                    .frame(width: proxy.size.width)
                }
            }
        }
        .transition(.identity)
    }
}

struct ProfileSelector_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSelector()
    }
}
