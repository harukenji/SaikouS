//
//  AnilistApiService.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

protocol AnilistApiServiceProtocol {
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async
    func mangaSearch(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async
    func recentEpisodes(completion: (RecentFetchResult) -> Void) async
    func recentChapters(completion: (RecentFetchResult) -> Void) async
    func fetchInfo(id: String, provider: String, completion: (InfoFetchResult) -> Void) async
    func fetchMangaInfo(id: String, provider: String, completion: (MangaFetchResult) -> Void) async
    func fetchEpisodes(id: String, provider: String, dubbed: Bool, completion: (EpisodeFetchResult) -> Void) async
    func fetchChapters(id: String, provider: String, completion: (ChapterFetchResult) -> Void) async
}

final class AnilistApiService: AnilistApiServiceProtocol {
    let baseUrl: String = "https://api.consumet.org/meta/anilist"
    
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async {
        guard let url = URL(string: "\(baseUrl)/advanced-search?query=\(query.replacingOccurrences(of: " ", with: "%20"))\(year.count > 0 ? "&year=" + year : "")\(season.count > 0 ? "&season=" + season : "")\(genres.count > 0 ? "&genres=" + ("%5B%22" + genres.joined(separator: "%22%2C%22") + "%22%5D") : "")\(format.count > 0 ? "&format=" + format : "")\(sort_by.count > 0 ? "&sort=%5B%22" + sort_by + "%22%5D" : "")") else {
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
    
    func mangaSearch(query: String, year: String, season: String, genres: [String], format: String, sort_by: String, completion: (SearchFetchResult) -> Void) async {
        guard let url = URL(string: "\(baseUrl)/advanced-search?query=\(query.replacingOccurrences(of: " ", with: "%20"))\(year.count > 0 ? "&year=" + year : "")&type=MANGA\(season.count > 0 ? "&season=" + season : "")\(genres.count > 0 ? "&genres=" + ("%5B%22" + genres.joined(separator: "%22%2C%22") + "%22%5D") : "")\(format.count > 0 ? "&format=" + format : "")\(sort_by.count > 0 ? "&sort=%5B%22" + sort_by + "%22%5D" : "")") else {
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
    
    func recentEpisodes(completion: (RecentFetchResult) -> Void) async {
        print("\(baseUrl)/advanced-search?type=ANIME&sort=%5B%22UPDATED_AT_DESC%22%5D&format=TV&status=RELEASING")
        guard let url = URL(string: "\(baseUrl)/advanced-search?type=ANIME&sort=[%22UPDATED_AT_DESC%22]&format=TV&status=RELEASING") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(RecentResults.self, from: data)
                completion(.success(data: data))
            } catch let error {
                print(error)
                completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch {
            completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
    
    func recentChapters(completion: (RecentFetchResult) -> Void) async {
        print("\(baseUrl)/advanced-search?type=MANGA&sort=%5B%22UPDATED_AT_DESC%22%5D&status=RELEASING")
        guard let url = URL(string: "\(baseUrl)/advanced-search?type=MANGA&sort=[%22UPDATED_AT_DESC%22]&status=RELEASING") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(RecentResults.self, from: data)
                completion(.success(data: data))
            } catch let error {
                print(error)
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
    
    func fetchMangaInfo(id: String, provider: String, completion: (MangaFetchResult) -> Void) async {
        guard let url = URL(string: "\(baseUrl)-manga/info/\(id)?provider=\(provider)") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(MangaInfoData.self, from: data)
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
    
    func fetchChapters(id: String, provider: String, completion: (ChapterFetchResult) -> Void) async {
        print("\(baseUrl)-manga/info/\(id)?provider=\(provider)")
        guard let url = URL(string: "\(baseUrl)-manga/info/\(id)?provider=\(provider)") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(MangaInfoData.self, from: data)
                if(data.chapters != nil) {
                    completion(.success(data: data.chapters!))
                } else {
                    completion(.failure(error: AnilistFetchError.dataLoadFailed))
                }
            } catch let error {
                completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch {
            completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
    
    func fetchSkipTimes(malId: Int, episodeNumber: Int, completion: (SkipTimesFetchResult) -> Void) async {
        guard let url = URL(string: "https://api.aniskip.com/v2/skip-times/\(malId)/\(episodeNumber)?types[]=ed&types[]=mixed-ed&types[]=mixed-op&types[]=op&types[]=recap&episodeLength=") else {
            completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode(SkipTimes.self, from: data)
                completion(.success(data: data))
            } catch let error {
                completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch {
            completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
}
