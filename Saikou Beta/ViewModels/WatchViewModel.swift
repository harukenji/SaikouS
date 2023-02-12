//
//  WatchViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

final class WatchViewModel: ObservableObject {
    @Published var episodedata: [Episode]? = nil
    @Published var error: AnilistFetchError? = nil
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func onAppear(id: String, provider: String, dubbed: Bool) {
        Task {
            await repository.fetchEpisodes(id: id, provider: provider, dubbed: dubbed){ result in
                switch result {
                    case .success(let data):
                        self.episodedata = data
                    case .failure(let reason):
                        self.error = reason
                }
            }
        }
    }
}
