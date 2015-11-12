//
//  Podcast.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import Foundation
import Parse

class Podcast {
    var title: String
    var thumbnailImageURL: String
    var largeImageURL: String
    var collectionId: Int
    var episodeCount: Int?
    var feedUrl: String
    var lastUpdated: String?
    var episodes = [Episode]()
    
    init(title: String, thumbnailImageURL: String, largeImageURL: String, collectionId: Int, episodeCount: Int?, feedUrl: String, lastUpdated: String)  {
        self.title = title
        self.thumbnailImageURL = thumbnailImageURL
        self.largeImageURL = largeImageURL
        self.collectionId = collectionId
        self.episodeCount = episodeCount
        self.feedUrl = feedUrl
        self.lastUpdated = lastUpdated
//        self.saveToParse()
    }
    
    func asPFObject() -> PFObject {
        let pfPodcast = PFObject(className: "Podcast")
        pfPodcast["title"] = title
        pfPodcast["thumbnailImageURL"] = thumbnailImageURL
        pfPodcast["largeImageURL"] = largeImageURL
        pfPodcast["collectionId"]  = collectionId
        pfPodcast["feedUrl"] = feedUrl
        return pfPodcast
    }
    
    func saveToParse() -> PFObject {
        let pfPodcast = PFObject(className: "Podcast")
        pfPodcast["title"] = title
        pfPodcast["thumbnailImageURL"] = thumbnailImageURL
        pfPodcast["largeImageURL"] = largeImageURL
        pfPodcast["collectionId"]  = collectionId
        pfPodcast["feedUrl"] = feedUrl
        pfPodcast.saveInBackground()
        return pfPodcast
    }
    
    init(pfPodcast: PFObject) {
        self.title = pfPodcast["title"] as! String
        self.thumbnailImageURL = pfPodcast["thumbnailImageURL"] as! String
        self.largeImageURL = pfPodcast["largeImageURL"] as! String
        self.collectionId = pfPodcast["collectionId"] as! Int
        self.episodeCount = nil
        self.feedUrl = pfPodcast["feedUrl"] as! String
//        self.lastUpdated = pfPodcast["lastUpdated"] as! String
    }
    
    class func podcastsWithJSON(allResults: NSArray) -> [Podcast] {

        var podcasts = [Podcast]()
        if allResults.count>0 {
            for podcastInfo in allResults {
                print(podcastInfo["releaseDate"])
                
                if let kind = podcastInfo["kind"] as? String {

                    if kind=="podcast" {
                        var name = podcastInfo["trackName"] as? String
                        if name == nil {
                            name = podcastInfo["collectionName"] as? String
                        }
                        if name == nil {
                            name = "Unknown"
                        }

                        let thumbnailURL = podcastInfo["artworkUrl60"] as? String ?? ""
                        let imageURL = podcastInfo["artworkUrl100"] as? String ?? ""
                        let feedUrl = podcastInfo["feedUrl"] as? String ?? ""
                        let episodeCount = podcastInfo["trackCount"] as? Int ?? 0
                        let collectionId = podcastInfo["collectionId"] as? Int ?? 0
                        let releaseDate = podcastInfo["releaseDate"] as? String ?? "????-??-??"
                        let lastUpdated = releaseDate.substringToIndex(releaseDate.startIndex.advancedBy(10))                        
                        let podcast = Podcast(title: name!, thumbnailImageURL: thumbnailURL, largeImageURL: imageURL, collectionId: collectionId, episodeCount: episodeCount, feedUrl: feedUrl, lastUpdated: lastUpdated)
                        
                        podcasts.append(podcast)
                    }
                }
            }
        }

        return podcasts
    }
}

extension Podcast: Equatable {}
    
func ==(_ lhs: Podcast, _ rhs: Podcast) -> Bool {
    return lhs.collectionId == rhs.collectionId

}