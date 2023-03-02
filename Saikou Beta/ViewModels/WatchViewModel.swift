//
//  WatchViewModel.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

final class WatchViewModel: ObservableObject {
    @Published var episodedata: [Episode]? = nil
    @Published var skiptimes: SkipTimes? = nil
    @Published var error: AnilistFetchError? = nil
    @Published var skipTypeText: String = ""
    
    private let repository: AnilistRepository
    
    init(repository: AnilistRepository = AnilistRepository()) {
        self.repository = repository
    }
    
    func getSkipTypeFormatted(type: String) -> String {
        switch type {
        case "op":
            return "Opening"
        case "ed":
            return "Ending"
        case "mixed-ed":
            return "Mixed Ending"
        case "mixed-op":
            return "Mixed Opening"
        case "recap":
            return "Recap"
        default:
            return "Opening"
        }
    }
    
    func showSkipButton(currentTime: Double) {
        if(skiptimes != nil && skiptimes!.results != nil) {
            let arr = skiptimes!.results!.filter {
                $0.interval.startTime <= currentTime && $0.interval.endTime >= currentTime
            }
            if(arr.count > 0) {
                skipTypeText = getSkipTypeFormatted(type: arr[0].skipType)
            } else {
                skipTypeText = ""
            }
        } else {
            skipTypeText = ""
        }
    }
    
    func getEndTime(type: String) -> Double {
        if(skiptimes != nil && skiptimes!.results != nil) {
            let arr = skiptimes!.results!.filter {
                $0.skipType == type
            }
            if(arr.count > 0) {
                return arr[0].interval.endTime
            }
            return 0.0
        }
        return 0.0
    }
    
    func getSkipPercentage(currentTime: Double) -> Double {
        if(skiptimes != nil && skiptimes!.results != nil) {
            let arr = skiptimes!.results!.filter {
                $0.interval.startTime <= currentTime && $0.interval.endTime >= currentTime
            }
            if(arr.count > 0) {
                let timeElapsed = currentTime - arr[0].interval.startTime
                let totalTime = arr[0].interval.endTime - arr[0].interval.startTime
                let percentage = timeElapsed / totalTime
                return percentage
            }
            return 0.0
        }
        return 0.0
    }
    
    func onAppear(id: String, provider: String, dubbed: Bool, malId: Int, episodeNumber: Int) {
        Task {
            await repository.fetchEpisodes(id: id, provider: provider, dubbed: dubbed){ result in
                switch result {
                    case .success(let data):
                        self.episodedata = data
                    case .failure(let reason):
                        self.error = reason
                }
            }
            
            await repository.fetchSkipTimes(malId: malId, episodeNumber: episodeNumber){ result in
                switch result {
                    case .success(let data):
                        self.skiptimes = data
                    case .failure(let reason):
                        self.error = reason
                }
            }
        }
    }
}
