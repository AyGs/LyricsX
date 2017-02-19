//
//  LyricsTTPod.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/13.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsTTPod: LyricsSource {
    
    func fetchLyrics(title: String, artist: String) -> [LXLyrics] {
        let urlStr = "http://lp.music.ttpod.com/lrc/down?lrcid=&artist=\(artist)&title=\(title)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url),
            let lrcContent = JSON(data)["data"]["lrc"].string,
            var lrc = LXLyrics(lrcContent)else {
            return []
        }
        
        var metadata: [LXLyrics.MetadataKey: Any] = [:]
        metadata[.source] = LXLyrics.Source.TTPod
        metadata[.searchTitle] = title
        metadata[.searchArtist] = artist
        
        lrc.metadata = metadata
        
        return [lrc]
    }
    
}

extension LXLyrics.Source {
    
    static let TTPod = "TTPod"
    
}