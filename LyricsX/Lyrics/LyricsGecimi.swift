//
//  LyricsGecimi.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/11.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsGecimi: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String, duration: TimeInterval, completionBlock: @escaping (Lyrics) -> Void) {
        queue.addOperation {
            let lrcDatas = self.searchLrcFor(title: title, artist: artist)
            for (index, lrcData) in lrcDatas.enumerated() {
                var metadata = lrcData
                metadata[.source]       = "Gecimi"
                metadata[.searchTitle]  = title
                metadata[.searchArtist] = artist
                metadata[.searchIndex]  = index
                if let lrc = Lyrics(metadata: metadata) {
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchLrcFor(title: String, artist: String) -> [[Lyrics.MetadataKey: Any]] {
        let urlStr = "http://gecimi.com/api/lyric/\(title)/\(artist)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["result"].array else {
            return []
        }
        
        return array.flatMap() { item in
            var result: [Lyrics.MetadataKey: Any] = [:]
            result[.lyricsURL] = item["lrc"].url
            
            if let aid = item["aid"].string,
                let url = URL(string:"http://gecimi.com/api/cover/\(aid)"),
                let data = try? Data(contentsOf: url),
                let artworkURL = JSON(data)["result"]["cover"].url {
                    result[.artworkURL] = artworkURL
            }
            return result
        }
    }

}
