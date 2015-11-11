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
    let coordinate: CLLocationCoordinate2D
    var subtitle: String?
    init(episode: Episode, coordinate: CLLocationCoordinate2D) {
        self.title = "\(episode.podcast.title): \(episode.title)"
        self.subtitle = episode.itunesSubtitle
        self.coordinate = coordinate
        super.init()
    }
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
    }
}