//
//  AnimeHomeViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//
import Foundation
import SwiftUI
import CoreData

final class AnimeHomeViewModel: ObservableObject {
    @Published var recentresults: RecentResults? = nil
    @Published var error: AnilistFetchError? = nil
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func fetchRecentEpisodes() async {
        await repository.recentEpisodes{ result in
            print(result)
                switch result {
                    case .success(let data):
                        self.recentresults = data
                    case .failure(let reason):
                        self.error = reason
                }
            }
        
    }
}
