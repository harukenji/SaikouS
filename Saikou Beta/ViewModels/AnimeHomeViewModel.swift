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
    @State var didRun: Bool = false
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func fetchRecentEpisodes() async {
        if(!didRun) {
            await repository.recentEpisodes{ result in
                print(result)
                switch result {
                case .success(let data):
                    print(self.recentresults)
                    self.recentresults = data
                    if(self.recentresults != nil) {
                        self.recentresults!.results = self.recentresults!.results.filter {
                            $0.countryOfOrigin != "CH"
                        }
                        didRun = true
                    }
                case .failure(let reason):
                    self.error = reason
                }
            }
        }
    }
}
