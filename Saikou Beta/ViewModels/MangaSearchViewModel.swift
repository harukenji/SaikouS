//
//  MangaSearchViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import Foundation
import SwiftUI
import CoreData

final class MangaSearchViewModel: ObservableObject {
    @Published var searchresults: SearchResults? = nil
    @Published var error: AnilistFetchError? = nil
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func onSearch(query: String, year: String, season: String, genres: [String], format: String, sort_by: String) {
        Task {
            await repository.mangaSearch(query:query,year:year,season:season,genres:genres,format:format,sort_by:sort_by){ result in
                switch result {
                    case .success(let data):
                        self.searchresults = data
                    case .failure(let reason):
                        self.error = reason
                }
            }
        }
    }
}
