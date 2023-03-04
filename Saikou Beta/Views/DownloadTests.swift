//
//  DownloadTests.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import SwiftUI

class FileDownloader {

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void) async {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                do {
                    let _ = try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                } catch let error {
                    completion(destinationUrl.path, error)
                }
            } catch let error {
                completion(destinationUrl.path, error)
            }
        }
    }
}

struct DownloadTests: View {
    @State var downloaded: Bool = false
    @State var filesDownloaded: Int = 0
    @State var erroredDownloads: Int = 0
    @State var images: [mangaImages]?
    @StateObject var viewModel: InfoViewModel = InfoViewModel()
    
    func getImages(id: String) async {
        guard let url = URL(string: "https://api.consumet.org/meta/anilist-manga/read?chapterId=\(id)&provider=mangadex") else {
            //completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode([mangaImages].self, from: data)
                images = data
                print(images)
                //completion(.success(data: data))
            } catch let error {
                print(error)
                //completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch let error {
            print(error)
            //completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
    
    var body: some View {
        VStack {
            
                Text("Downloaded: \(filesDownloaded)")
            
                Text("Errored: \(erroredDownloads)")
        }
            .onAppear {
                Task {
                    await getImages(id: "0615033f-404c-4a57-a595-613a6277f553")
                    print(images)
                    if(images != nil) {
                        for index in 0..<images!.count {
                            await FileDownloader.loadFileAsync(url: URL(string: images![index].img)!) { result,error  in
                                if error != nil {
                                    erroredDownloads += 1
                                } else {
                                    filesDownloaded += 1
                                }
                            }
                        }
                    }
                }
            }
    }
}

struct DownloadTests_Previews: PreviewProvider {
    static var previews: some View {
        DownloadTests()
    }
}
