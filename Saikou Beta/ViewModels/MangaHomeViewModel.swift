//
//  MangaHomeViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import Foundation
import SwiftUI
import CoreData

final class MangaHomeViewModel: ObservableObject {
    @Published var recentresults: RecentResults? = nil
    @Published var error: AnilistFetchError? = nil
    @State var didRun: Bool = false
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func fetchRecentChapters() async {
        if(!didRun) {
            await repository.recentChapters{ result in
                print(result)
                switch result {
                case .success(let data):
                    print(self.recentresults)
                    self.recentresults = data
                    didRun = true
                case .failure(let reason):
                    self.error = reason
                }
            }
        }
    }
}
