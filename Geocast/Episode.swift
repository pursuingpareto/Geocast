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
    var duration: Int?
    var gmDuration: CMTime?
    var pubDate: String!
    var podcast: Podcast!
    
    var approximateSecondsListenedToByUser: Int
    
    var summary: String?
//    var categories = [String]()
    
    var itunesSummary: String?
    var itunesSubtitle: String?
//    var itunesExplicit: Bool = false
    
    init(title: String, mp3Url: String, duration: Int?, pubDate: String, podcast: Podcast)  {
        self.title = title
        self.mp3Url = mp3Url
        self.duration = duration
        self.pubDate = pubDate
        self.podcast = podcast
        self.approximateSecondsListenedToByUser = 0
     }
    
    class func durationFromString(string: String) -> Int? {
        var seconds: Int?
        
        var fractionalTime = string.characters.split { $0 == "." }.map { String($0) }
        var wholeTime = fractionalTime[0]
        var splitTime = wholeTime.characters.split { $0 == ":" }.map { String($0) }
        switch splitTime.count {
        case 1:
            seconds = Int(splitTime[0])
        case 2:
            if let mins = Int(splitTime[0]) {
                if let secs = Int(splitTime[1]) {
                    seconds = 60 * mins + secs
                }
            }
        case 3:
            if let hours = Int(splitTime[0]) {
                if let mins = Int(splitTime[1]) {
                    if let secs = Int(splitTime[2]) {
                        seconds = 3600 * hours + 60 * mins + secs
                    }
                }
            }
        default:
            seconds = nil
        }
        return seconds
    }
    
    class func durationAsString(durationInSeconds seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds - (hours * 3600)) / 60
        let secs = (seconds - (hours * 3600) - (mins * 60))
        if hours == 0 {
            return "\(mins):\(secs)"
        } else {
            return "\(hours):\(mins):\(secs)"
        }
        
    }
    
    init(parsedFeedData dataDict: Dictionary<String, String>, podcast: Podcast) {
        self.podcast = podcast
        self.approximateSecondsListenedToByUser = 0
        self.title = dataDict["title"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.mp3Url = dataDict["mp3Url"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if let durationString: String = dataDict["itunes:duration"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            self.duration = Episode.durationFromString(durationString)
        }
        self.pubDate = dataDict["pubDate"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.summary = dataDict["description"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.itunesSummary = dataDict["itunes:summary"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.itunesSubtitle = dataDict["itunes:subtitle"]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(mp3Url, forKey: PropertyKey.mp3UrlKey)
        aCoder.encodeObject(duration, forKey: PropertyKey.durationKey)
        aCoder.encodeObject(pubDate, forKey: PropertyKey.pubDateKey)
        aCoder.encodeObject(podcast, forKey: PropertyKey.podcastKey)
        aCoder.encodeObject(approximateSecondsListenedToByUser, forKey: PropertyKey.approximateSecondsListenedToByUserKey)
        aCoder.encodeObject(summary, forKey: PropertyKey.summaryKey)
        aCoder.encodeObject(itunesSubtitle, forKey: PropertyKey.itunesSubtitleKey)
        aCoder.encodeObject(itunesSummary, forKey: PropertyKey.itunesSummaryKey) 
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let mp3Url = aDecoder.decodeObjectForKey(PropertyKey.mp3UrlKey) as! String
        let duration: Int?
        if let d = aDecoder.decodeObjectForKey(PropertyKey.durationKey) as? Int {
            duration = d
        } else {
            duration = nil
        }
//        let duration = aDecoder.decodeObjectForKey(PropertyKey.durationKey) as? Int
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
        self.duration = Episode.durationFromString(pfEpisode["duration"] as! String)
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