//
//  Episode.swift
//  Geocast
//
//  Created by Andrew Brown on 11/8/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import Foundation
import Parse
import CoreMedia

class Episode: NSObject, NSCoding {
    
    struct PropertyKey {
        static let titleKey = "title"
        static let mp3UrlKey = "mp3Url"
        static let durationKey = "duration"
        static let pubDateKey = "pubDate"
        static let podcastKey = "podcast"
        static let approximateSecondsListenedToByUserKey = "approximateSecondsListenedToByUser"
        static let summaryKey = "summary"
        static let itunesSummaryKey = "itunesSummary"
        static let itunesSubtitleKey = "itunesSubtitle"
    }
    
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    class func archiveURLforPodcast(podcast: Podcast) -> NSURL {
        return DocumentsDirectory.URLByAppendingPathComponent("\(podcast.collectionId)")
    }
    
    var title: String!
    var mp3Url : String!
    var duration: String!
    var gmDuration: CMTime?
    var pubDate: String!
    var podcast: Podcast!
    
    var approximateSecondsListenedToByUser: Int
    
    var summary: String?
//    var categories = [String]()
    
    var itunesSummary: String?
    var itunesSubtitle: String?
//    var itunesExplicit: Bool = false
    
    init(title: String, mp3Url: String, duration: String, pubDate: String, podcast: Podcast)  {
        self.title = title
        self.mp3Url = mp3Url
        self.duration = duration
        self.pubDate = pubDate
        self.podcast = podcast
        self.approximateSecondsListenedToByUser = 0
     }
    
    init(parsedFeedData dataDict: Dictionary<String, String>, podcast: Podcast) {
        self.podcast = podcast
        self.approximateSecondsListenedToByUser = 0
        self.title = dataDict["title"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.mp3Url = dataDict["mp3Url"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.duration = dataDict["itunes:duration"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.pubDate = dataDict["pubDate"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.summary = dataDict["description"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.itunesSummary = dataDict["itunes:summary"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.itunesSubtitle = dataDict["itunes:subtitle"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey) as! String
        aCoder.encodeObject(mp3Url, forKey: PropertyKey.mp3UrlKey) as! String
        aCoder.encodeObject(duration, forKey: PropertyKey.durationKey) as! String
        aCoder.encodeObject(pubDate, forKey: PropertyKey.pubDateKey) as! String
        aCoder.encodeObject(podcast, forKey: PropertyKey.podcastKey) as! Podcast
        aCoder.encodeObject(approximateSecondsListenedToByUser, forKey: PropertyKey.approximateSecondsListenedToByUserKey) as! Int
        aCoder.encodeObject(summary, forKey: PropertyKey.summaryKey) as? String
        aCoder.encodeObject(itunesSubtitle, forKey: PropertyKey.itunesSubtitleKey) as? String
        aCoder.encodeObject(itunesSummary, forKey: PropertyKey.itunesSummaryKey) as? String
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let mp3Url = aDecoder.decodeObjectForKey(PropertyKey.mp3UrlKey) as! String
        let duration = aDecoder.decodeObjectForKey(PropertyKey.durationKey) as! String
        let pubDate = aDecoder.decodeObjectForKey(PropertyKey.pubDateKey) as! String
        let podcast = aDecoder.decodeObjectForKey(PropertyKey.podcastKey) as! Podcast
        
        self.init(title: title, mp3Url: mp3Url, duration: duration, pubDate: pubDate, podcast: podcast)
        
        let approximateSecondsListenedToByUser = aDecoder.decodeObjectForKey(PropertyKey.approximateSecondsListenedToByUserKey) as! Int
        let summary = aDecoder.decodeObjectForKey(PropertyKey.summaryKey) as? String
        let itunesSubtitle = aDecoder.decodeObjectForKey(PropertyKey.itunesSubtitleKey) as? String
        let itunesSummary = aDecoder.decodeObjectForKey(PropertyKey.itunesSummaryKey) as? String
        
        self.approximateSecondsListenedToByUser = approximateSecondsListenedToByUser
        self.summary = summary
        self.itunesSubtitle = itunesSubtitle
        self.itunesSummary = itunesSummary
    }
    
    init(pfEpisode: PFObject){
        self.podcast = Podcast(pfPodcast: pfEpisode["podcast"] as! PFObject)
        self.title = pfEpisode["title"] as! String
        self.mp3Url = pfEpisode["mp3Url"] as! String
        self.duration = pfEpisode["duration"] as! String
        self.pubDate = pfEpisode["pubDate"] as! String
        self.summary = pfEpisode["summary"] as? String
        self.itunesSummary = pfEpisode["itunesSummary"] as? String
        self.itunesSubtitle = pfEpisode["itunesSubtitle"] as? String
        self.approximateSecondsListenedToByUser = 0
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
    
    override var description : String {
        return "title: \(title)\nduration: \(duration)\nmp3Url: \(mp3Url)\npubDate: \(pubDate)\nsummary: \(summary)\nitunesSum: \(itunesSummary)\nitunesSub: \(itunesSubtitle)\n\n"
    }
    
    
    
    
}