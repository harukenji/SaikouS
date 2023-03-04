//
//  InfoViewViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

final class InfoViewModel: ObservableObject {
    @Published var infodata: InfoData? = nil
    @Published var mangaInfodata: MangaInfoData? = nil
    @Published var episodedata: [Episode]? = nil
    @Published var chapterdata: [Chapter]? = nil
    @Published var error: AnilistFetchError? = nil
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func onAppear(id: String, provider: String, type: String) {
        print(type)
        print(id)
        Task {
            if(type == "anime") {
                await repository.fetchInfo(id: id, provider: provider) { result in
                    switch result {
                    case .success(let data):
                        self.infodata = data
                        self.error = nil
                    case .failure(let reason):
                        self.error = reason
                    }
                }
            } else if(type == "manga") {
                await repository.fetchMangaInfo(id: id, provider: provider) { result in
                    switch result {
                    case .success(let data):
                        self.mangaInfodata = data
                        if(mangaInfodata != nil) {
                            self.chapterdata = mangaInfodata!.chapters
                        }
                        self.error = nil
                    case .failure(let reason):
                        self.error = reason
                    }
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
                        self.error = nil
                    case .failure(let reason):
                        self.error = reason
                }
            }
        }
    }
    
    func fetchChapters(id: String, provider: String) async {
        Task {
            await repository.fetchChapters(id: id, provider: provider) { result in
                switch result {
                    case .success(let data):
                        self.chapterdata = data
                        if(self.mangaInfodata != nil) {
                            self.mangaInfodata!.chapters = data
                        }
                    self.error = nil
                    case .failure(let reason):
                    print(reason)
                        self.error = reason
                }
            }
        }
    }
}
