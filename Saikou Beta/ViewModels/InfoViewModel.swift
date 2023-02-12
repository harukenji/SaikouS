//
//  InfoViewViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

final class InfoViewModel: ObservableObject {
    @Published var infodata: InfoData? = nil
    @Published var episodedata: [Episode]? = nil
    @Published var error: AnilistFetchError? = nil
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func onAppear(id: String, provider: String) {
        Task {
            await repository.fetchInfo(id: id, provider: provider) { result in
                switch result {
                    case .success(let data):
                        self.infodata = data
                    case .failure(let reason):
                        self.error = reason
                }
            }
        }
    }
    
    func fetchEpisodes(id: String, provider: String, dubbed: Bool) async {
        Task {
            await repository.fetchEpisodes(id: id, provider: provider, dubbed: dubbed) { result in
                switch result {
                    case .success(let data):
                        self.episodedata = data
                        if(self.infodata != nil) {
                            self.infodata!.episodes = self.episodedata
                        }
                    case .failure(let reason):
                        self.error = reason
                }
            }
        }
    }
}
