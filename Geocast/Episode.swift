//
//  Episode.swift
//  Geocast
//
//  Created by Andrew Brown on 11/8/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import Foundation
import Parse

class Episode {
//    var podcast : Podcast!
    var title: String!
    var mp3Url : String!
    var duration: String!
    var pubDate: String!
    var podcast: Podcast!
    
    var summary: String?
//    var categories = [String]()
    
    var itunesSummary: String?
    var itunesSubtitle: String?
//    var itunesExplicit: Bool = false
    
    init(parsedFeedData dataDict: Dictionary<String, String>, podcast: Podcast) {
        self.podcast = podcast
        self.title = dataDict["title"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.mp3Url = dataDict["mp3Url"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.duration = dataDict["itunes:duration"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.pubDate = dataDict["pubDate"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.summary = dataDict["description"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.itunesSummary = dataDict["itunes:summary"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.itunesSubtitle = dataDict["itunes:subtitle"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func saveToParse(withPFPodcast pfPodcast: PFObject) -> PFObject {
        let pfEpisode = PFObject(className: "Episode")
        pfEpisode["title"] = title
        pfEpisode["mp3Url"] = mp3Url
        pfEpisode["duration"] = duration
        pfEpisode["pubDate"] = pubDate
        pfEpisode["summary"] = summary
        pfEpisode["itunesSummary"] = itunesSummary
        pfEpisode["itunesSubtitle"] = itunesSubtitle
        pfEpisode["podcast"] = pfPodcast
        pfEpisode.saveInBackground()
        return pfEpisode
    }
    
    var description : String {
        return "title: \(title)\nduration: \(duration)\nmp3Url: \(mp3Url)\npubDate: \(pubDate)\nsummary: \(summary)\nitunesSum: \(itunesSummary)\nitunesSub: \(itunesSubtitle)\n\n"
    }
    
    
    
}