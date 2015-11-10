//
//  Podcast.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import Foundation

class Podcast {
    var title: String
    var thumbnailImageURL: String
    var largeImageURL: String
    var collectionId: Int
    var episodeCount: Int
    var feedUrl: String
    var episodes = [Episode]()
    
    init(title: String, thumbnailImageURL: String, largeImageURL: String, collectionId: Int, episodeCount: Int, feedUrl: String)  {
        self.title = title
        self.thumbnailImageURL = thumbnailImageURL
        self.largeImageURL = largeImageURL
        self.collectionId = collectionId
        self.episodeCount = episodeCount
        self.feedUrl = feedUrl
    }
    
    class func podcastsWithJSON(allResults: NSArray) -> [Podcast] {

        var podcasts = [Podcast]()
        if allResults.count>0 {
            for podcastInfo in allResults {
                
                if let kind = podcastInfo["kind"] as? String {

                    if kind=="podcast" {
                        var name = podcastInfo["trackName"] as? String
                        if name == nil {
                            name = podcastInfo["collectionName"] as? String
                        }
                        if name == nil {
                            name = "Unknown"
                        }
                        println(name)
                        let thumbnailURL = podcastInfo["artworkUrl60"] as? String ?? ""
                        let imageURL = podcastInfo["artworkUrl100"] as? String ?? ""
                        let feedUrl = podcastInfo["feedUrl"] as? String ?? ""
                        let episodeCount = podcastInfo["trackCount"] as? Int ?? 0
                        let collectionId = podcastInfo["collectionId"] as? Int ?? 0
                        
                        var podcast = Podcast(title: name!, thumbnailImageURL: thumbnailURL, largeImageURL: imageURL, collectionId: collectionId, episodeCount: episodeCount, feedUrl: feedUrl)
                        
                        podcasts.append(podcast)
                    }
                }
            }
        }
        println(podcasts)
        return podcasts
    }
}