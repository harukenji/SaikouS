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
import CoreData

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
    let id: Int
    let name: String
    let avatar: String
    let banner: String
    let episodesWatched: Int
    let chaptersRead: Int
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

struct Home: View {
    @State var query = ""
    @StateObject var anilist: Anilist = Anilist()
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: SearchViewModel = SearchViewModel()
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
    @State var user: userData? = nil
    @State var watchList: [AnimeEntry]? = nil
    @State var plannedList: [AnimeEntry]? = nil
    @State var favouritesList: favourites? = nil
    @State var mangaWatchList: [AnimeEntry]? = nil
    @State var mangaPlannedList: [AnimeEntry]? = nil
    @State var mangaFavouritesList: favourites? = nil
    
    let pub = NotificationCenter.default
        .publisher(for: .authCodeUrl)
    
    let columns = [
        GridItem(.adaptive(minimum: 100), alignment: .top)
    ]
    
    func getUserData() async {
        let query = """
            query CurrentUser {
                Viewer {
                  id
                  name
                  avatar {
                    large
                  }
                  bannerImage
                  statistics {
                    anime {
                      episodesWatched
                    }
                    manga {
                      chaptersRead
                    }
                  }
                }
              }
        """
        let jsonData = try? JSONSerialization.data(withJSONObject: ["query": query])
        
        let url = URL(string: "https://graphql.anilist.co")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        print("getting token")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            do {
                let data = try JSONDecoder().decode(userInfoData.self, from: data)
                user = userData(id: data.data.Viewer.id, name: data.data.Viewer.name, avatar: data.data.Viewer.avatar.large, banner: data.data.Viewer.bannerImage ?? "", episodesWatched: data.data.Viewer.statistics.anime.episodesWatched, chaptersRead: data.data.Viewer.statistics.manga.chaptersRead)
                await getUserLists()
            } catch let error {
                print(error.localizedDescription)
                debugText = error.localizedDescription
                debugTitle = "User data parsing failed"
                showDebug = true
            }
        } catch let error {
            print(error.localizedDescription)
            debugText = error.localizedDescription
            debugTitle = "User Data fecthing failed"
            showDebug = true
        }
        
       //task.resume()
    }
    
    func getUserLists() async {
        if(user != nil) {
            let query = """
        {
          MediaListCollection(userId: \(user!.id), type: ANIME) {
            lists {
              name
              isCustomList
              isCompletedList: isSplitCompletedList
              entries {
                ...mediaListEntry
              }
            }
            user {
              id
              name
              avatar {
                large
              }
              mediaListOptions {
                scoreFormat
                rowOrder
                animeList {
                  sectionOrder
                  customLists
                  splitCompletedSectionByFormat
                  theme
                }
                mangaList {
                  sectionOrder
                  customLists
                  splitCompletedSectionByFormat
                  theme
                }
              }
            }
          }
        }
        
        fragment mediaListEntry on MediaList {
          progress
          media {
            id
            title {
              romaji
              english
            }
            coverImage {
              extraLarge
              large
            }
            episodes
            averageScore
          }
        }
        """
            
            let jsonData = try? JSONSerialization.data(withJSONObject: ["query": query])
            
            let url = URL(string: "https://graphql.anilist.co")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            print("getting user lists")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                do {
                    let data = try JSONDecoder().decode(userList.self, from: data)
                    let temp =  data.data.MediaListCollection.lists?.filter {
                        $0.name == "Watching"
                    }
                    if(temp != nil && temp!.count > 0) {
                        watchList = temp![0].entries
                    }
                    
                    let planningtemp =  data.data.MediaListCollection.lists?.filter {
                        $0.name == "Planning"
                    }
                    if(planningtemp != nil && planningtemp!.count > 0) {
                        plannedList = planningtemp![0].entries
                    }
                    await getFavourites(type: "anime", page: 1)
                } catch let error {
                    print(error.localizedDescription)
                    print(error)
                    debugText = error.localizedDescription
                    debugTitle = "User list parsing Failed"
                    showDebug = true
                }
            } catch let error {
                print(error.localizedDescription)
                debugText = error.localizedDescription
                debugTitle = "User list Fetching Failed"
                showDebug = true
            }
        }
    }
    
    func getMangaLists() async {
        if(user != nil) {
            let query = """
        {
          MediaListCollection(userId: \(user!.id), type: MANGA) {
            lists {
              name
              isCustomList
              isCompletedList: isSplitCompletedList
              entries {
                ...mediaListEntry
              }
            }
            user {
              id
              name
              avatar {
                large
              }
              mediaListOptions {
                scoreFormat
                rowOrder
                animeList {
                  sectionOrder
                  customLists
                  splitCompletedSectionByFormat
                  theme
                }
                mangaList {
                  sectionOrder
                  customLists
                  splitCompletedSectionByFormat
                  theme
                }
              }
            }
          }
        }
        
        fragment mediaListEntry on MediaList {
          progress
          media {
            id
            title {
              romaji
              english
            }
            coverImage {
              extraLarge
              large
            }
            episodes
            averageScore
          }
        }
        """
            
            let jsonData = try? JSONSerialization.data(withJSONObject: ["query": query])
            
            let url = URL(string: "https://graphql.anilist.co")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            print("getting user lists")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                do {
                    let data = try JSONDecoder().decode(userList.self, from: data)
                    let temp =  data.data.MediaListCollection.lists?.filter {
                        $0.name == "Watching"
                    }
                    if(temp != nil && temp!.count > 0) {
                        mangaWatchList = temp![0].entries
                    }
                    
                    let planningtemp =  data.data.MediaListCollection.lists?.filter {
                        $0.name == "Planning"
                    }
                    if(planningtemp != nil && planningtemp!.count > 0) {
                        mangaPlannedList = planningtemp![0].entries
                    }
                    await getFavourites(type: "manga", page: 1)
                } catch let error {
                    print(error.localizedDescription)
                    print(error)
                    debugText = error.localizedDescription
                    debugTitle = "User list parsing Failed"
                    showDebug = true
                }
            } catch let error {
                print(error.localizedDescription)
                debugText = error.localizedDescription
                debugTitle = "User list Fetching Failed"
                showDebug = true
            }
        }
    }
    
    func getFavourites(type: String, page: Int) async {
        if(user != nil) {
            let query = """
                        {User(id:\(user!.id)){id favourites{\(type)(page:\(page)){pageInfo{hasNextPage}edges{favouriteOrder node{id idMal isAdult mediaListEntry{ progress private score(format:POINT_100) status } chapters isFavourite episodes nextAiringEpisode{episode}meanScore isFavourite title{english romaji userPreferred}type status(version:2)bannerImage coverImage{large}}}}}}}
                        """
            
            let jsonData = try? JSONSerialization.data(withJSONObject: ["query": query])
            
            let url = URL(string: "https://graphql.anilist.co")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            print("getting user favourites")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                do {
                    let data = try JSONDecoder().decode(favourites.self, from: data)
                    if(type == "anime") {
                        favouritesList = data
                    } else {
                        mangaFavouritesList = data
                    }
                } catch let error {
                    print(error.localizedDescription)
                    print(error)
                    debugText = error.localizedDescription
                    debugTitle = "User favourites parsing Failed"
                    showDebug = true
                }
            } catch let error {
                print(error.localizedDescription)
                debugText = error.localizedDescription
                debugTitle = "User favourites Fetching Failed"
                showDebug = true
            }
        }
    }
    
    @State var access_token: String = ""
    @FetchRequest(sortDescriptors: []) var userStorageData: FetchedResults<UserStorageInfo>
    
    func setAccessToken(token: String) {
        access_token = token
        let userDataInfo = UserStorageInfo(context: moc)
        userDataInfo.access_token = token
        userDataInfo.id = UUID()
        
        do {
            print("Trying to save data")
            try moc.save()
            print(userStorageData)
        } catch let error {
            print(error.localizedDescription)
            debugText = error.localizedDescription
            debugTitle = "Storing Failed"
            showDebug = true
        }
        
    }
    
    @State var showDebug = false
    @State var debugTitle = ""
    @State var debugText = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    Color(.black)
                    
                    TabView(selection: $selectedItem) {
                        AnimeHome(proxy: proxy)
                            .padding(.top, -70)
                            .tag(0)
                        
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
                                        if let url = URL(string: "https://anilist.co/api/v2/oauth/authorize?client_id=11248&response_type=token") {
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
                                            Task {
                                                setAccessToken(token: output.userInfo!["myText"]! as! String)
                                                await getUserData()
                                                //showDebug = true
                                            }
                                        }
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
                                        .fixedSize()
                                        .cornerRadius(16)
                                        .padding(.vertical, 28)
                                    }
                                }
                                .frame(maxWidth: proxy.size.width)
                                .padding(.top, 250)
                            } else {
                                VStack(alignment: .leading) {
                                    AnilistInfoTopBanner(user: user!, width: proxy.size.width)
                                    
                                    if(watchList != nil) {
                                        
                                        Text("Currently Watching")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .heavy))
                                            .padding(.top, 20)
                                            .padding(.leading, 20)
                                    
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<watchList!.count) {index in
                                                    NavigationLink(destination: Info(id: String(watchList![index].media.id), type: "anime")) {
                                                        AnimeCard(image: watchList![index].media.coverImage.extraLarge ?? watchList![index].media.coverImage.large, rating: watchList![index].media.averageScore, title: watchList![index].media.title.english ?? watchList![index].media.title.romaji, currentEpisodeCount: watchList![index].progress, totalEpisodes: watchList![index].media.episodes)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                    }
                                    
                                    if(favouritesList != nil && favouritesList!.data.User.favourites.anime.edges.count > 0) {
                                        Text("Favourite Anime")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .heavy))
                                            .padding(.top, 20)
                                            .padding(.leading, 20)
                                    
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<favouritesList!.data.User.favourites.anime.edges.count) {index in
                                                    NavigationLink(destination: Info(id: String(favouritesList!.data.User.favourites.anime.edges[index].node.id), type: "anime")) {
                                                        AnimeCard(image: favouritesList!.data.User.favourites.anime.edges[index].node.coverImage.large, rating: favouritesList!.data.User.favourites.anime.edges[index].node.meanScore, title: favouritesList!.data.User.favourites.anime.edges[index].node.title.english ?? favouritesList!.data.User.favourites.anime.edges[index].node.title.romaji, currentEpisodeCount: favouritesList!.data.User.favourites.anime.edges[index].node.nextAiringEpisode?.episode, totalEpisodes: favouritesList!.data.User.favourites.anime.edges[index].node.episodes)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                    }
                                    
                                    if(plannedList != nil) {
                                        Text("Planned Anime")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .heavy))
                                            .padding(.top, 20)
                                            .padding(.leading, 20)
                                    
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<plannedList!.count) {index in
                                                    NavigationLink(destination: Info(id: String(plannedList![index].media.id), type: "anime")) {
                                                        AnimeCard(image: plannedList![index].media.coverImage.extraLarge ?? plannedList![index].media.coverImage.large, rating: plannedList![index].media.averageScore, title: plannedList![index].media.title.english ?? plannedList![index].media.title.romaji, currentEpisodeCount: plannedList![index].progress, totalEpisodes: plannedList![index].media.episodes)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                    }
                                    
                                    if(mangaWatchList != nil) {
                                        
                                        Text("Currently Reading")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .heavy))
                                            .padding(.top, 20)
                                            .padding(.leading, 20)
                                    
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<mangaWatchList!.count) {index in
                                                    AnimeCard(image: mangaWatchList![index].media.coverImage.extraLarge ?? mangaWatchList![index].media.coverImage.large, rating: mangaWatchList![index].media.averageScore, title: mangaWatchList![index].media.title.english ?? mangaWatchList![index].media.title.romaji, currentEpisodeCount: mangaWatchList![index].progress, totalEpisodes: mangaWatchList![index].media.episodes)
                                                    
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                    }
                                    
                                    if(mangaFavouritesList != nil && mangaFavouritesList!.data.User.favourites.anime.edges.count > 0) {
                                        Text("Favourite Manga")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .heavy))
                                            .padding(.top, 20)
                                            .padding(.leading, 20)
                                    
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<mangaFavouritesList!.data.User.favourites.anime.edges.count) {index in
                                                    AnimeCard(image: mangaFavouritesList!.data.User.favourites.anime.edges[index].node.coverImage.large, rating: mangaFavouritesList!.data.User.favourites.anime.edges[index].node.meanScore, title: mangaFavouritesList!.data.User.favourites.anime.edges[index].node.title.english ?? mangaFavouritesList!.data.User.favourites.anime.edges[index].node.title.romaji, currentEpisodeCount: mangaFavouritesList!.data.User.favourites.anime.edges[index].node.nextAiringEpisode?.episode, totalEpisodes: mangaFavouritesList!.data.User.favourites.anime.edges[index].node.episodes)
                                                    
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                    }
                                    
                                    if(mangaPlannedList != nil) {
                                        Text("Planned Anime")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .heavy))
                                            .padding(.top, 20)
                                            .padding(.leading, 20)
                                    
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<mangaPlannedList!.count) {index in
                                                    AnimeCard(image: mangaPlannedList![index].media.coverImage.extraLarge ?? mangaPlannedList![index].media.coverImage.large, rating: mangaPlannedList![index].media.averageScore, title: mangaPlannedList![index].media.title.english ?? mangaPlannedList![index].media.title.romaji, currentEpisodeCount: mangaPlannedList![index].progress, totalEpisodes: mangaPlannedList![index].media.episodes)
                                                    
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                    }
                                }
                            }
                        }
                        .navigationBarHidden(true)
                        .tag(1)
                        
                        MangaHome(proxy: proxy)
                            .padding(.top, -70)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                    .animation(.easeInOut)
                    .transition(.slide)
                    .popover(isPresented: $showDebug) {
                        VStack {
                            Text(debugTitle)
                            Text(debugText)
                        }
                    }
                    
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
                .onAppear {
                    Task {
                        print("A WILD APP APPEARED!")
                        if(userStorageData.count > 0) {
                            access_token = userStorageData[0].access_token ?? ""
                        }
                        if(access_token.count > 0) {
                            await getUserData()
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
        }
        .accentColor(Color(hex: "#00000000"))
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
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
            .onAppear {
                Task {
                    try? await Task.sleep(nanoseconds: 4_000_000_000)
                    anilist.error = nil
                }
            }
        }
    }
}
