//
//  MapEpisodeAnnotation.swift
//  Geocast
//
//  Created by Andrew Brown on 11/9/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import Foundation
import MapKit

class MapEpisodeAnnotation: NSObject, MKAnnotation {
    let title: String?
    var imageURL: String?
    var image: UIImage? = nil
    let coordinate: CLLocationCoordinate2D
    var subtitle: String?
    var episode: Episode?
    var address: String?
    
    init(episode: Episode, coordinate: CLLocationCoordinate2D) {
        self.title = "\(episode.podcast.title): \(episode.title)"
        self.subtitle = episode.itunesSubtitle
        self.coordinate = coordinate
        self.imageURL = episode.podcast.thumbnailImageURL
        self.episode = episode
        super.init()
        if let url = imageURL {
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string: url)!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:
                {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if error == nil {
                        self.image = UIImage(data: data!)
                        
                        // Store the image in to our cache
                        //                    self.imageCache[url] = image
                    }
            })
        }
    }
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, imageURL: String?, episode: Episode, address: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.imageURL = imageURL
        self.episode = episode
        self.address = address
        super.init()
        if let url = imageURL {
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string: url)!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:
                {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    self.image = UIImage(data: data!)
                    
                    // Store the image in to our cache
//                    self.imageCache[url] = image
                    }
                })
        }
        
    }
}