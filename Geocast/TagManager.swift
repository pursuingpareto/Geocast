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
    
    func addTag(forEpisode episode: Episode, atLocation location: CLLocation) {
        let annotation = MapEpisodeAnnotation(episode: episode, coordinate: location.coordinate)
        
        // try to get Podcast associated with annotation
        var query = PFQuery(className: "Podcast")
        query.whereKey("collectionId", equalTo: episode.podcast.collectionId)
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            var pfPodcast: PFObject!
            
            if error == nil && objects?.count > 0 {
                // podcast exists
                
                print("PODCAST EXISTS")
                
                pfPodcast = objects![0]
                
                print(pfPodcast)
            } else {
                
                print("CREATING PODCAST IN PARSE")
                pfPodcast = episode.podcast.saveToParse()
            }
            
            // try to get Episode associated with annotation
            query = PFQuery(className: "Episode")
            query.whereKey("mp3Url", equalTo: episode.mp3Url)
            query.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                var pfEpisode: PFObject!
                if error == nil && objects?.count > 0{
                    pfEpisode = objects![0]
                } else {
                    pfEpisode = episode.saveToParse(withPFPodcast: pfPodcast)
                }
                
                // add geotag
                print("ADDING GEOTAG")
                let pfTag = PFObject(className: "Tag")
                pfTag["podcast"] = pfPodcast
                pfTag["episode"] = pfEpisode
                pfTag["user"] = PFUser.currentUser()!
                let point = PFGeoPoint(location: location)
                pfTag["location"] = point
                pfTag.saveInBackground()
            })
        })
        
        tags.append(annotation)
    }
    
    private func getTags() -> [MapEpisodeAnnotation]{
        return tags
    }
    
    func getTagsFromParse(nearGeoPoint geoPoint: PFGeoPoint) -> [MapEpisodeAnnotation]? {
        let query = PFQuery(className: "Tag")
        query.whereKey("location", nearGeoPoint: geoPoint)
        query.includeKey("podcast")
        query.includeKey("episode")
        do {
            let tagObjects = try query.findObjects() as [PFObject]
            var tags: [MapEpisodeAnnotation] = []
            
            for tagObject in tagObjects {
                print("tagObject is \(tagObject)")
                let pfPodcast = tagObject["podcast"] as! PFObject
                let pfEpisode = tagObject["episode"] as! PFObject
                let pfLocation = tagObject["location"] as! PFGeoPoint
                let tag = MapEpisodeAnnotation(title: pfPodcast["title"] as! String, subtitle: pfEpisode["title"] as! String, coordinate: CLLocationCoordinate2DMake(pfLocation.latitude, pfLocation.longitude))
                tags.append(tag)
            }
            self.tags = tags
            
        } catch {
            print("errror caught")
        }
        return getTags()
    }
}