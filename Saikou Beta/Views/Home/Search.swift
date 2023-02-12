//
//  Search.swift
//  Saikou Beta
//
//  Created by Inumaki on 04.02.23.
//

import SwiftUI
import Kingfisher
import WebKit
import AuthenticationServices
import Combine

@available(iOS 15.0, *)
struct AdaptiveSheet<T: View>: ViewModifier {
    let sheetContent: T
    @Binding var isPresented: Bool
    let detents : [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    
    init(isPresented: Binding<Bool>, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> T) {
        self.sheetContent = content()
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self._isPresented = isPresented
    }
    func body(content: Content) -> some View {
        ZStack{
            content
            CustomSheet_UI(isPresented: $isPresented, detents: detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: {sheetContent}).frame(width: 0, height: 0)
        }
    }
}
@available(iOS 15.0, *)
extension View {
    func adaptiveSheet<T: View>(isPresented: Binding<Bool>, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> T)-> some View {
        modifier(AdaptiveSheet(isPresented: isPresented, detents : detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: content))
    }
}

@available(iOS 15.0, *)
struct CustomSheet_UI<Content: View>: UIViewControllerRepresentable {
    
    let content: Content
    @Binding var isPresented: Bool
    let detents : [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    
    init(isPresented: Binding<Bool>, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self._isPresented = isPresented
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> CustomSheetViewController<Content> {
        let vc = CustomSheetViewController(coordinator: context.coordinator, detents : detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge:  prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: {content})
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CustomSheetViewController<Content>, context: Context) {
        if isPresented{
            uiViewController.presentModalView()
        }else{
            uiViewController.dismissModalView()
        }
    }
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var parent: CustomSheet_UI
        init(_ parent: CustomSheet_UI) {
            self.parent = parent
        }
        //Adjust the variable when the user dismisses with a swipe
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if parent.isPresented{
                parent.isPresented = false
            }
            
        }
        
    }
}

@available(iOS 15.0, *)
class CustomSheetViewController<Content: View>: UIViewController {
    let content: Content
    let coordinator: CustomSheet_UI<Content>.Coordinator
    let detents : [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    init(coordinator: CustomSheet_UI<Content>.Coordinator, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.coordinator = coordinator
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func dismissModalView(){
        dismiss(animated: true, completion: nil)
    }
    func presentModalView(){
        
        let hostingController = UIHostingController(rootView: content)
        
        hostingController.modalPresentationStyle = .popover
        hostingController.presentationController?.delegate = coordinator as UIAdaptivePresentationControllerDelegate
        hostingController.modalTransitionStyle = .coverVertical
        if let hostPopover = hostingController.popoverPresentationController {
            hostPopover.sourceView = super.view
            let sheet = hostPopover.adaptiveSheetPresentationController
            //As of 13 Beta 4 if .medium() is the only detent in landscape error occurs
            sheet.detents = (isLandscape ? [.large()] : detents)
            sheet.largestUndimmedDetentIdentifier =
            smallestUndimmedDetentIdentifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge =
            prefersScrollingExpandsWhenScrolledToEdge
            sheet.prefersEdgeAttachedInCompactHeight =
            prefersEdgeAttachedInCompactHeight
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            
        }
        if presentedViewController == nil{
            present(hostingController, animated: true, completion: nil)
        }
    }
    /// To compensate for orientation as of 13 Beta 4 only [.large()] works for landscape
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            isLandscape = true
            self.presentedViewController?.popoverPresentationController?.adaptiveSheetPresentationController.detents = [.large()]
        } else {
            isLandscape = false
            self.presentedViewController?.popoverPresentationController?.adaptiveSheetPresentationController.detents = detents
        }
    }
}

struct userData {
    let name: String
    let avatar: String
    let episodesWatched: Int
}

struct RectCorner: OptionSet {
    
    let rawValue: Int
        
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomRight = RectCorner(rawValue: 1 << 2)
    static let bottomLeft = RectCorner(rawValue: 1 << 3)
    
    static let allCorners: RectCorner = [.topLeft, topRight, .bottomLeft, .bottomRight]
}


// draws shape with specified rounded corners applying corner radius
struct RoundedCornersShape: Shape {
    
    var radius: CGFloat = .zero
    var corners: RectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
        let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )

        let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
        let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )

        let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
        let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )

        let p7 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
        let p8 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )

        
        path.move(to: p1)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: p2,
                    radius: radius)
        path.addLine(to: p3)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: p4,
                    radius: radius)
        path.addLine(to: p5)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: p6,
                    radius: radius)
        path.addLine(to: p7)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                    tangent2End: p8,
                    radius: radius)
        path.closeSubpath()

        return path
    }
}

extension View {
    func roundedCorners(radius: CGFloat, corners: RectCorner) -> some View {
        clipShape( RoundedCornersShape(radius: radius, corners: corners) )
    }
}

struct RoundCorner: Shape {
    
    // MARK: - PROPERTIES
    
    var cornerRadius: CGFloat
    var maskedCorners: UIRectCorner
    
    
    // MARK: - PATH
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: maskedCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return Path(path.cgPath)
    }
}

struct Search: View {
    @State var query = ""
    @StateObject var anilist: Anilist = Anilist()
    @State var focused = false
    
    @State var resultDisplayGrid = true
    @State private var selectedItem = 1
    @State private var showingPopover = false
    
    let supportedGenres = [
        "Action",
        "Adventure",
        "Cars",
        "Comedy",
        "Drama",
        "Fantasy",
        "Horror",
        "Mahou Shoujo",
        "Mecha",
        "Music",
        "Mystery",
        "Psychological",
        "Romance",
        "Sci-Fi",
        "Slice of Life",
        "Sports",
        "Supernatural",
        "Thriller"
    ]
    let supportedSorting = [
        "POPULARITY_DESC",
        "POPULARITY",
        "TRENDING_DESC",
        "TRENDING",
        "UPDATED_AT_DESC",
        "UPDATED_AT",
        "START_DATE_DESC",
        "START_DATE",
        "END_DATE_DESC",
        "END_DATE",
        "FAVOURITES_DESC",
        "FAVOURITES",
        "SCORE_DESC",
        "SCORE",
        "TITLE_ROMAJI_DESC",
        "TITLE_ROMAJI",
        "TITLE_ENGLISH_DESC",
        "TITLE_ENGLISH",
        "TITLE_NATIVE_DESC",
        "TITLE_NATIVE",
        "EPISODES_DESC",
        "EPISODES",
        "ID",
        "ID_DESC"
    ]
    let supportedFormats = [
        "TV",
        "TV_SHORT",
        "OVA",
        "ONA",
        "MOVIE",
        "SPECIAL",
        "MUSIC"
    ]
    let minYear = 1970
    let maxYear = 2023
    
    @State var selectedYear: String = ""
    @State var selectedSeason: String = ""
    @State var selectedSorting: String = ""
    @State var selectedFormat: String = ""
    @State var selectedGenres: [String] = []
    
    @State var showWebView = false
    @State var access_token = ""
    @State var user: userData? = nil
    
    let pub = NotificationCenter.default
        .publisher(for: .authCodeUrl)
    
    let columns = [
        GridItem(.adaptive(minimum: 100), alignment: .top)
    ]
    
    func login(code: String) {
        let body: [String: Any] = ["grant_type": "authorization_code", "client_id": "11248", "client_secret": "WjdqqTH1oOxbKl6gcjaPkRBdqv4X8xwBrv1iuOL7", "redirect_uri": "com.saikouSwift://redirect", "code": code]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        let url = URL(string: "https://anilist.co/api/v2/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("getting token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("-----> data: \(data)")
            print("-----> error: \(error)")
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            print("-----1> responseJSON: \(responseJSON)")
            if let responseJSON = responseJSON as? [String: Any] {
                print("-----2> responseJSON: \(responseJSON)")
                access_token = responseJSON["access_token"] as! String
                getUserData()
            }
        }
        
        task.resume()
    }
    
    func getUserData() {
        let query = """
            query CurrentUser {
                Viewer {
                  id
                  name
                  avatar {
                    large
                  }
                  statistics {
                    anime {
                      episodesWatched
                    }
                  }
                }
              }
        """
        let jsonData = try? JSONSerialization.data(withJSONObject: ["query": query])
        
        let url = URL(string: "https://graphql.anilist.co")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        print("getting token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("-----> data: \(data)")
            print("-----> error: \(error)")
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            print("-----1> responseJSON: \(responseJSON)")
            if let responseJSON = responseJSON as? [String: Any] {
                print("-----2> responseJSON: \(responseJSON)")
                user = userData(name: ((responseJSON["data"] as! [String: Any])["Viewer"] as! [String: Any])["name"] as! String, avatar: (((responseJSON["data"] as! [String: Any])["Viewer"] as! [String: Any])["avatar"] as! [String: Any])["large"] as! String, episodesWatched: ((((responseJSON["data"] as! [String: Any])["Viewer"] as! [String: Any])["statistics"] as! [String: Any])["anime"] as! [String: Any])["episodesWatched"] as! Int)
            }
        }
        
        task.resume()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    Color(.black)
                    
                    TabView(selection: $selectedItem) {
                        ScrollView {
                            VStack {
                                ZStack {
                                    TextField("Search for an anime...", text: $query, onEditingChanged: { (editingChanged) in
                                        focused = editingChanged
                                    })
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.leading, 20)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 40)
                                            .stroke(focused ? Color(hex: "#ff4cb0") : Color.white.opacity(0.7), lineWidth: focused ? 2 : 1)
                                    )
                                    .onSubmit {
                                        Task {
                                            await anilist.search(query: query.replacingOccurrences(of: " ", with: "%20"), year: selectedYear, season: selectedSeason, genres: selectedGenres, format: selectedFormat, sort_by: selectedSorting)
                                        }
                                    }
                                    .animation(.spring())
                                    
                                    ZStack {
                                        Color(.black)
                                        
                                        Text("ANIME")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(focused ? Color(hex: "#ff4cb0") : Color(hex: "#8b8789"))
                                            .padding(.horizontal, 6)
                                            .animation(.spring())
                                    }
                                    .fixedSize()
                                    .padding(.trailing, 270)
                                    .padding(.bottom, 46)
                                }
                                .padding(.bottom, 10)
                                
                                HStack {
                                    Button(action: {
                                        showingPopover = true
                                    }) {
                                        ZStack {
                                            Color(hex: "#1c1b1f")
                                            
                                            HStack {
                                                Image("filter-solid")
                                                    .resizable()
                                                    .frame(maxWidth: 24, maxHeight: 24)
                                                    .foregroundColor(Color(hex: "#ff4cb0"))
                                                
                                                Text("Filter")
                                                    .foregroundColor(Color(hex: "#ff4cb0"))
                                                    .font(.system(size: 18, weight: .heavy))
                                            }
                                            .padding(16)
                                        }
                                        .fixedSize()
                                        .cornerRadius(12)
                                    }
                                }
                                .frame(maxWidth: proxy.size.width, alignment: .trailing)
                                .padding(.bottom, 14)
                                
                                HStack {
                                    Text("Search Results")
                                        .font(.system(size: 20, weight: .heavy))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        resultDisplayGrid = false
                                    }) {
                                        Image("list")
                                            .resizable()
                                            .frame(maxWidth: 16, maxHeight: 16)
                                            .foregroundColor(.white.opacity(!resultDisplayGrid ? 1.0 : 0.7))
                                            .padding(.trailing, 12)
                                    }
                                    
                                    Button(action: {
                                        resultDisplayGrid = true
                                    }) {
                                        Image("grid")
                                            .resizable()
                                            .frame(maxWidth: 16, maxHeight: 16)
                                            .foregroundColor(.white.opacity(resultDisplayGrid ? 1.0 : 0.7))
                                    }
                                }
                                .padding(.bottom, 20)
                                
                                if(anilist.searchresults != nil) {
                                    if(resultDisplayGrid) {
                                        LazyVGrid(columns: columns, spacing: 20) {
                                            ForEach(0..<anilist.searchresults!.results.count) { index in
                                                NavigationLink(destination: Info(id: anilist.searchresults!.results[index].id)) {
                                                    VStack {
                                                        ZStack(alignment: .bottomTrailing) {
                                                            KFImage(URL(string: anilist.searchresults!.results[index].image))
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 110, height: 160)
                                                                .frame(maxWidth: 110, maxHeight: 160)
                                                                .cornerRadius(16)
                                                            
                                                            ZStack {
                                                                Rectangle()
                                                                    .foregroundColor(Color(hex: "#C0ff5dae"))
                                                                
                                                                Text(anilist.searchresults!.results[index].rating != nil ? String(format: "%.1f", Float(anilist.searchresults!.results[index].rating!) / 10) : "0.0")
                                                                    .font(.system(size: 12, weight: .heavy))
                                                                    .padding(.vertical, 4)
                                                                    .padding(.horizontal, 10)
                                                            }
                                                            .fixedSize()
                                                            .cornerRadius(18, corners: [.topLeft])
                                                        }
                                                        .frame(maxWidth: 110, maxHeight: 160)
                                                        .cornerRadius(16)
                                                        .clipped()
                                                        
                                                        Text("\(anilist.searchresults!.results[index].title.english ?? anilist.searchresults!.results[index].title.romaji)")
                                                            .frame(maxWidth: 110, alignment: .leading)
                                                            .lineLimit(3)
                                                            .font(.system(size: 14))
                                                            .multilineTextAlignment(.leading)
                                                        HStack {
                                                            Text(anilist.searchresults!.results[index].currentEpisodeCount != nil ? String(anilist.searchresults!.results[index].currentEpisodeCount!) : "~")
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(hex: "#8da2f8"))
                                                            
                                                            Text(anilist.searchresults!.results[index].totalEpisodes != nil ? "| " + String(anilist.searchresults!.results[index].totalEpisodes!) : "| ~")
                                                                .font(.system(size: 16))
                                                                .foregroundColor(.white).opacity(0.7)
                                                                .padding(.leading, -3)
                                                        }
                                                        .frame(maxWidth: 110, alignment: .leading)
                                                    }
                                                    .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    } else {
                                        ForEach(0..<anilist.searchresults!.results.count) { index in
                                            NavigationLink(destination: Info(id: anilist.searchresults!.results[index].id)) {
                                                ZStack(alignment: .center) {
                                                    KFImage(URL(string: anilist.searchresults!.results[index].cover ?? anilist.searchresults!.results[index].image))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: proxy.size.width - 40, height: 200)
                                                        .frame(maxWidth: proxy.size.width - 40, maxHeight: 200)
                                                        .cornerRadius(30)
                                                    
                                                    
                                                    Rectangle()
                                                        .fill(LinearGradient(
                                                            gradient: Gradient(stops: [
                                                                .init(color: Color(hex: "#001C1C1C"), location: 0.4),
                                                                .init(color: Color(hex: "#901C1C1C"), location: 0.671875),
                                                                .init(color: Color(hex: "#ff1C1C1C"), location: 0.7864583134651184)]),
                                                            startPoint: UnitPoint(x: 0, y: 0),
                                                            endPoint: UnitPoint(x: 0, y: 1)))
                                                        .frame(width: proxy.size.width - 40, height: 200)
                                                        .cornerRadius(30)
                                                    
                                                    HStack(alignment: .bottom) {
                                                        ZStack(alignment: .bottomTrailing) {
                                                            KFImage(URL(string: anilist.searchresults!.results[index].image))
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 110, height: 160)
                                                                .frame(maxWidth: 110, maxHeight: 160)
                                                                .cornerRadius(12)
                                                            
                                                            ZStack {
                                                                Rectangle()
                                                                    .foregroundColor(Color(hex: "#80ff5dae"))
                                                                
                                                                Text(anilist.searchresults!.results[index].rating != nil ? String(format: "%.1f", Float(anilist.searchresults!.results[index].rating!) / 10) : "0.0")
                                                                    .font(.system(size: 12, weight: .heavy))
                                                                    .padding(.vertical, 6)
                                                                    .padding(.horizontal, 8)
                                                            }
                                                            .fixedSize()
                                                            .cornerRadius(30, corners: [.topLeft])
                                                        }
                                                        .frame(maxWidth: 110, maxHeight: 160)
                                                        .cornerRadius(12)
                                                        .clipped()
                                                        
                                                        VStack {
                                                            Text(anilist.searchresults!.results[index].title.romaji)
                                                                .fontWeight(.heavy)
                                                                .lineLimit(2)
                                                                .multilineTextAlignment(.leading)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .padding(.bottom, 6)
                                                            
                                                            Text(String(anilist.searchresults!.results[index].totalEpisodes ?? 0) + " Episodes")
                                                                .font(.system(size: 16))
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                        
                                                    }
                                                    .padding(.horizontal, 20)
                                                    
                                                }
                                                .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                        .tag(0)
                        .adaptiveSheet(isPresented: $showingPopover, detents: [.medium()], smallestUndimmedDetentIdentifier: .large){
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .foregroundColor(
                                    Color(hex: "#1c1b1f"))
                                .overlay {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image("filter-solid")
                                                .resizable()
                                                .frame(maxWidth: 24, maxHeight: 24)
                                                .foregroundColor(Color(hex: "#cbc4d1"))
                                            
                                            Text("Filter")
                                                .foregroundColor(Color(hex: "#eeeeee"))
                                                .font(.system(size: 18, weight: .heavy))
                                            
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 22)
                                        .padding(.horizontal, 20)
                                        
                                        VStack {
                                            HStack {
                                                Menu {
                                                    ForEach(0..<supportedSorting.count) {index in
                                                        Button {
                                                            // do something
                                                            selectedSorting = supportedSorting[index]
                                                            print(selectedSorting)
                                                        } label: {
                                                            Text(supportedSorting[index])
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text("Sort By")
                                                            .foregroundColor(Color(hex: "#969295"))
                                                            .font(.system(size: 16, weight: .heavy))
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "arrowtriangle.down.fill")
                                                            .resizable()
                                                            .frame(maxWidth: 12, maxHeight: 6)
                                                            .foregroundColor(Color(hex: "#969295"))
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    }
                                                }
                                                
                                                Spacer()
                                                    .frame(maxWidth: 20)
                                                
                                                
                                                Menu {
                                                    ForEach(0..<supportedFormats.count) {index in
                                                        Button {
                                                            // do something
                                                            selectedFormat = supportedFormats[index]
                                                            print(selectedFormat)
                                                        } label: {
                                                            Text(supportedFormats[index])
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text("Format")
                                                            .foregroundColor(Color(hex: "#969295"))
                                                            .font(.system(size: 16, weight: .heavy))
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "arrowtriangle.down.fill")
                                                            .resizable()
                                                            .frame(maxWidth: 12, maxHeight: 6)
                                                            .foregroundColor(Color(hex: "#969295"))
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 20)
                                            
                                            HStack {
                                                Menu {
                                                    Button {
                                                        // do something
                                                        selectedSeason = "SPRING"
                                                    } label: {
                                                        Text("SPRING")
                                                    }
                                                    Button {
                                                        // do something
                                                        selectedSeason = "SUMMER"
                                                    } label: {
                                                        Text("SUMMER")
                                                    }
                                                    Button {
                                                        // do something
                                                        selectedSeason = "FALL"
                                                    } label: {
                                                        Text("FALL")
                                                    }
                                                    Button {
                                                        // do something
                                                        selectedSeason = "WINTER"
                                                    } label: {
                                                        Text("WINTER")
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text("Season")
                                                            .foregroundColor(Color(hex: "#969295"))
                                                            .font(.system(size: 16, weight: .heavy))
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "arrowtriangle.down.fill")
                                                            .resizable()
                                                            .frame(maxWidth: 12, maxHeight: 6)
                                                            .foregroundColor(Color(hex: "#969295"))
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    }
                                                }
                                                
                                                Spacer()
                                                    .frame(maxWidth: 20)
                                                
                                                Menu {
                                                    ForEach((minYear...maxYear).reversed(), id: \.self) {index in
                                                        Button {
                                                            // do something
                                                            selectedYear = String(index)
                                                            print(selectedYear)
                                                        } label: {
                                                            Text(String(index))
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text(selectedYear.count > 0 ? selectedYear : "Year")
                                                            .foregroundColor(Color(hex: "#969295"))
                                                            .font(.system(size: 16, weight: .heavy))
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "arrowtriangle.down.fill")
                                                            .resizable()
                                                            .frame(maxWidth: 12, maxHeight: 6)
                                                            .foregroundColor(Color(hex: "#969295"))
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Genres")
                                                .font(.system(size: 18, weight: .heavy))
                                                .padding(.leading, 12)
                                                .padding(.bottom, 6)
                                                .padding(.horizontal, 20)
                                            
                                            ScrollView(.horizontal) {
                                                HStack(spacing: 12) {
                                                    ForEach(0..<supportedGenres.count) {index in
                                                        ZStack {
                                                            Color.white.opacity(selectedGenres.contains(supportedGenres[index]) ? 1.0 : 0.0)
                                                            
                                                            Text(supportedGenres[index])
                                                                .font(.system(size: 16, weight: .heavy))
                                                                .foregroundColor(Color(hex: selectedGenres.contains(supportedGenres[index]) ? "#000000" : "#e7e1e5"))
                                                                .padding(.vertical, 8)
                                                                .padding(.horizontal, 12)
                                                        }
                                                        .frame(maxHeight: 30)
                                                        .overlay {
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                                        }
                                                        .onTapGesture {
                                                            if(selectedGenres.contains(supportedGenres[index])) {
                                                                selectedGenres.remove(at: selectedGenres.index(of: supportedGenres[index]) ?? 0)
                                                            } else {
                                                                selectedGenres.append(supportedGenres[index])
                                                            }
                                                            print(selectedGenres)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.leading, 20)
                                        }
                                        .padding(.top, 12)
                                        
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Button(action: {}) {
                                                Text("Cancel")
                                                    .foregroundColor(Color(hex: "#ff4cb0"))
                                                    .font(.system(size: 20, weight: .heavy))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    }.onTapGesture {
                                                        selectedYear = ""
                                                        selectedGenres = []
                                                        selectedFormat = ""
                                                        selectedSeason = ""
                                                        selectedSorting = ""
                                                        showingPopover.toggle()
                                                    }
                                            }
                                            
                                            Spacer()
                                                .frame(maxWidth: 20)
                                            
                                            
                                            Button(action: {}) {
                                                Text("Apply")
                                                    .foregroundColor(Color(hex: "#ff4cb0"))
                                                    .font(.system(size: 20, weight: .heavy))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    }.onTapGesture {
                                                        showingPopover.toggle()
                                                    }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        ScrollView {
                            if(user == nil) {
                                VStack {
                                    Text("Saikou S")
                                        .font(.system(size: 90, weight: .ultraLight))
                                        .foregroundColor(Color(hex: "#ff4cb0"))
                                        .padding(.bottom, 12)
                                    
                                    Text("The Best Anime & Manga app for iOS")
                                        .padding(.horizontal, 60)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        print("LOGIN")
                                        //showWebView.toggle()
                                        if let url = URL(string: "https://anilist.co/api/v2/oauth/authorize?client_id=11248&redirect_uri=com.saikouSwift://redirect&response_type=code") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        ZStack {
                                            Color(hex: "#ff4cb0")
                                            
                                            HStack {
                                                Image("anilist")
                                                    .resizable()
                                                    .frame(maxWidth: 20, maxHeight: 15)
                                                    .foregroundColor(Color(hex: "#ffc5e5"))
                                                    .padding(.leading, 30)
                                                
                                                Text("Login")
                                                    .fontWeight(.heavy)
                                                    .foregroundColor(Color(hex: "#ffc5e5"))
                                                    .frame(width: 50)
                                                    .padding(.vertical, 20)
                                                    .padding(.trailing, 50)
                                                    .padding(.leading, 30)
                                            }
                                        }
                                        .fixedSize()
                                        .cornerRadius(16)
                                        .padding(.vertical, 28)
                                        .onReceive(pub) { (output) in
                                            let code = output.userInfo!["myText"]!
                                            
                                            login(code: code as! String)
                                        }
                                        
                                    }
                                }
                                .frame(maxWidth: proxy.size.width, alignment: .center)
                                .padding(.top, 120)
                            } else {
                                VStack {
                                    ZStack(alignment: .top) {
                                        KFImage(URL(string: user!.avatar))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: proxy.size.width, maxHeight: 90)
                                            .clipped()
                                        
                                        Rectangle()
                                            .fill(LinearGradient(
                                                    gradient: Gradient(stops: [
                                                .init(color: Color(hex: "#00000000"), location: 0),
                                                .init(color: Color(hex: "#ff000000"), location: 1)]),
                                                    startPoint: UnitPoint(x: 0, y: 0),
                                                    endPoint: UnitPoint(x: 0, y: 1)))
                                            .frame(maxWidth: proxy.size.width, maxHeight: 90)
                                        
                                        HStack(alignment: .center) {
                                            VStack(alignment: .leading) {
                                                Text(user!.name)
                                                    .fontWeight(.heavy)
                                                
                                                HStack {
                                                    Text("Episodes watched")
                                                        .foregroundColor(.white.opacity(0.7))
                                                        .font(.system(size: 12))
                                                    Text("\(user!.episodesWatched)")
                                                        .foregroundColor(Color(hex: "#91a6ff"))
                                                        .font(.system(size: 12, weight: .heavy))
                                                        .padding(.leading, -4)
                                                }
                                            }
                                            .frame(maxHeight: 90, alignment: .center)
                                            
                                            Spacer()
                                            
                                            KFImage(URL(string: user!.avatar))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: 40, maxHeight: 40)
                                                .cornerRadius(40)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .frame(maxWidth: proxy.size.width, maxHeight: 90)
                                }
                                .frame(maxWidth: proxy.size.width, alignment: .top)
                            }
                        }
                        .navigationBarHidden(true)
                        .tag(1)
                        
                        Text("Manga")
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut)
                    .transition(.slide)
                    
                    ZStack {
                        ZStack {
                            Color(hex: "#1c1c1c")
                            
                            HStack {
                                VStack {
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .frame(minWidth: 28, minHeight: 20)
                                        .frame(maxWidth: 28, maxHeight: 20)
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    if(selectedItem == 0) {
                                        Rectangle()
                                            .foregroundColor(Color(hex: "#8ca7ff"))
                                            .frame(maxWidth: 18, maxHeight: 3)
                                    }
                                }
                                .padding(.top, selectedItem == 0 ? 8 : 0)
                                .onTapGesture {
                                    selectedItem = 0
                                }
                                
                                VStack {
                                    Text("HOME")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(Color(hex: "#ff4cb0"))
                                    
                                    if(selectedItem == 1) {
                                        Rectangle()
                                            .foregroundColor(Color(hex: "#8ca7ff"))
                                            .frame(maxWidth: 18, maxHeight: 3)
                                    }
                                }
                                .frame(width: 70)
                                .padding(.top, selectedItem == 1 ? 8 : 0)
                                .padding(.trailing, 24)
                                .padding(.leading, 24)
                                .onTapGesture {
                                    selectedItem = 1
                                }
                                
                                VStack {
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .frame(minWidth: 28, minHeight: 20)
                                        .frame(maxWidth: 28, maxHeight: 20)
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    if(selectedItem == 2) {
                                        Rectangle()
                                            .foregroundColor(Color(hex: "#8ca7ff"))
                                            .frame(maxWidth: 18, maxHeight: 3)
                                    }
                                }
                                .padding(.top, selectedItem == 2 ? 8 : 0)
                                .onTapGesture {
                                    selectedItem = 2
                                }
                            }
                            .padding(.horizontal, 44)
                            .padding(.top, 14)
                            .padding(.bottom, 12)
                        }
                        .fixedSize()
                        .cornerRadius(40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 70)
                }
            }
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .overlay {
            VStack {
                ZStack {
                    Color(hex: "1C1C1C")
                    
                    VStack(alignment: .leading) {
                        Text("An Error Occured")
                            .font(.system(size: 22, weight: .heavy))
                            .padding(.bottom, 12)
                        
                        Text(anilist.error?.localizedDescription ?? "")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 20)
                }
                .fixedSize(horizontal: false, vertical: true)
                .clipShape(
                    RoundCorner(
                        cornerRadius: 20,
                        maskedCorners: [.topLeft, .topRight]
                    )//OUR CUSTOM SHAPE
                )
                .frame(maxHeight: 220, alignment: .bottom)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .opacity(anilist.error != nil ? 1.0 : 0.0)
            .animation(.spring(response: 0.3))
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
