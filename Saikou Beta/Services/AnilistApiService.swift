//
//  AnilistApiService.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

protocol AnilistApiServiceProtocol {
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async
    func fetchInfo(id: String, provider: String, completion: (InfoFetchResult) -> Void) async
    func fetchEpisodes(id: String, provider: String, dubbed: Bool, completion: (EpisodeFetchResult) -> Void) async
}

final class AnilistApiService: AnilistApiServiceProtocol {
    let baseUrl: String = "https://api.consumet.org/meta/anilist"
    
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async {
        guard let url = URL(string: "\(baseUrl)/advanced-search?query=\(query)\(year.count > 0 ? "&year=" + year : "")\(season.count > 0 ? "&season=" + season : "")\(genres.count > 0 ? "&genres=" + ("%5B%22" + genres.joined(separator: "%22%2C%22") + "%22%5D") : "")\(format.count > 0 ? "&format=" + format : "")\(sort_by.count > 0 ? "&sort=%5B%22" + sort_by + "%22%5D" : "")") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(.success(data: data))
            } catch let error {
                completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch {
            completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
    
    func fetchInfo(id: String, provider: String, completion: (InfoFetchResult) -> Void) async {
        guard let url = URL(string: "\(baseUrl)/data/\(id)?fetchFiller=true&provider=\(provider)") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(InfoData.self, from: data)
                completion(.success(data: data))
            } catch let error {
                completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch {
            completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
    
    func fetchEpisodes(id: String, provider: String, dubbed: Bool, completion: (EpisodeFetchResult) -> Void) async {
        guard let url = URL(string: "\(baseUrl)/episodes/\(id)?fetchFiller=true&provider=\(provider)&dub=\(dubbed)") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode([Episode].self, from: data)
                completion(.success(data: data))
            } catch let error {
                completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch {
            completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
}
