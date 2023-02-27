//
//  AnilistRepository.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

protocol AnilistRepositoyProtocol {
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async
    func recentEpisodes(completion: (RecentFetchResult) -> Void) async
    func fetchInfo(id: String, provider: String, completion: (InfoFetchResult) -> Void) async
    func fetchEpisodes(id: String, provider: String, dubbed: Bool, completion: (EpisodeFetchResult) -> Void) async
}

final class AnilistRepository: AnilistRepositoyProtocol {
    private let apiService: AnilistApiService
    
    init(apiService: AnilistApiService = AnilistApiService()) {
        self.apiService = apiService
    }
    
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async {
        await apiService.search(query: query, year: year, season: season, genres: genres, format: format, sort_by: sort_by, completion: completion)
    }
    
    func recentEpisodes(completion: (RecentFetchResult) -> Void) async {
        await apiService.recentEpisodes(completion: completion)
    }
    
    func fetchInfo(id: String, provider: String, completion: (InfoFetchResult) -> Void) async {
        await apiService.fetchInfo(id: id, provider: provider, completion: completion)
    }
    
    func fetchEpisodes(id: String, provider: String, dubbed: Bool, completion: (EpisodeFetchResult) -> Void) async {
        await apiService.fetchEpisodes(id: id, provider: provider, dubbed: dubbed, completion: completion)
    }
}
