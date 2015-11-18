//
//  TagManager.swift
//  Geocast
//
//  Created by Andrew Brown on 11/10/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import Foundation
import MapKit
import Parse

class TagManager : NSObject {
    
    private var tags: [MapEpisodeAnnotation] = []
    
    class var sharedInstance: TagManager {
        struct Singleton {
            static let instance = TagManager()
        }
        return Singleton.instance
    }
    
    func addTag(forEpisode episode: Episode, atLocation location: CLLocation, withName name: String, withDescription description: String, withAddress address: String) {
        let annotation = MapEpisodeAnnotation(episode: episode, coordinate: location.coordinate)
        
        // try to get Podcast associated with annotation
        var query = PFQuery(className: "Podcast")
        query.whereKey("collectionId", equalTo: episode.podcast.collectionId)
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            var pfPodcast: PFObject!
            
            if error == nil && objects?.count > 0 {
                // podcast exists
                
 
                
                pfPodcast = objects![0]
                print("found podcast \(pfPodcast)")
                
            } else {
                pfPodcast = episode.podcast.saveToParse()
                print("created podcast \(pfPodcast)")
            }
            
            print("Now getting the episode")
            
            // try to get Episode associated with annotation
            query = PFQuery(className: "Episode")
            query.whereKey("mp3Url", equalTo: episode.mp3Url)
            query.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                var pfEpisode: PFObject!
                if error == nil && objects?.count > 0{
                    pfEpisode = objects![0]
                    print("found episode \(pfEpisode)")
                } else {
                    pfEpisode = episode.saveToParse(withPFPodcast: pfPodcast)
                    print("created episode \(pfEpisode)")
                }
                
                // add geotag

                let pfTag = PFObject(className: "Tag")
                pfTag["podcast"] = pfPodcast
                pfTag["episode"] = pfEpisode
                pfTag["user"] = PFUser.currentUser()!
                let point = PFGeoPoint(location: location)
                pfTag["location"] = point
                pfTag["locationName"] = name
                pfTag["tagDescription"] = description
                pfTag["address"] = address
                print("about to save tag")
                pfTag.saveInBackground()
            })
        })
        
        tags.append(annotation)
    }
    
    private func getTags() -> [MapEpisodeAnnotation]{
        print("tags \(tags)")
        return tags
    }
    
    func getTagsFromParse(nearGeoPoint geoPoint: PFGeoPoint) -> [MapEpisodeAnnotation]? {
        let query = PFQuery(className: "Tag")
        query.whereKey("location", nearGeoPoint: geoPoint)
        query.includeKey("podcast")
        query.includeKey("episode")
        
//        query.findObjectsInBackgroundWithBlock({
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            var tags: [MapEpisodeAnnotation] = []
//            
//            for tagObject in objects! {
//                
//                let pfPodcast = tagObject["podcast"] as! PFObject
//                let pfEpisode = tagObject["episode"] as! PFObject
//                let pfLocation = tagObject["location"] as! PFGeoPoint
//                let episode = Episode(pfEpisode: pfEpisode)
//                let tag = MapEpisodeAnnotation(title: pfPodcast["title"] as! String, subtitle: pfEpisode["title"] as! String, coordinate: CLLocationCoordinate2DMake(pfLocation.latitude, pfLocation.longitude), imageURL: pfPodcast["thumbnailImageURL"] as? String, episode: episode)
//                tags.append(tag)
//            }
//            self.tags = tags
//            print("dese tags\(tags)")
//        })
        
        do {
            let tagObjects = try query.findObjects() as [PFObject]
            var tags: [MapEpisodeAnnotation] = []
            
            for tagObject in tagObjects {

                let pfPodcast = tagObject["podcast"] as! PFObject
                let pfEpisode = tagObject["episode"] as! PFObject
                let pfLocation = tagObject["location"] as! PFGeoPoint
                let pfAddress = tagObject["address"] as! String
                let pfDescription = tagObject["tagDescription"] as! String
                let pfLocationName = tagObject["locationName"] as! String
                let episode = Episode(pfEpisode: pfEpisode)
                let tag = MapEpisodeAnnotation(title: pfPodcast["title"] as! String, subtitle: pfEpisode["title"] as! String, coordinate: CLLocationCoordinate2DMake(pfLocation.latitude, pfLocation.longitude), imageURL: pfPodcast["thumbnailImageURL"] as? String, episode: episode, address: pfAddress, tagDescription: pfDescription, locationName: pfLocationName)
                tags.append(tag)
            }
            self.tags = tags
            
        } catch {
            print("errror caught")
        }
        return getTags()
    }
}