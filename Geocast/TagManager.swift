//
//  TagManager.swift
//  Geocast
//
//  Created by Andrew Brown on 11/10/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import Foundation
import MapKit

class TagManager : NSObject {
    
    private var tags: [MapEpisodeAnnotation] = []
    
    class var sharedInstance: TagManager {
        struct Singleton {
            static let instance = TagManager()
        }
        return Singleton.instance
    }
    
    func addTag(forEpisode episode: Episode, atCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MapEpisodeAnnotation(episode: episode, coordinate: coordinate)
        tags.append(annotation)
    }
    
    func getTags() -> [MapEpisodeAnnotation]{
        return tags
    }
}