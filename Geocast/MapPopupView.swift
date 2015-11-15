//
//  MapPopupView.swift
//  Geocast
//
//  Created by Andrew Brown on 11/14/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit

class MapPopupView: UIView {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
//        createSubviews()
//        addAllSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        
        super.init(coder: aDecoder)
//        createSubviews()
//        addAllSubviews()
    }
    
    func setupConstraints() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        episodeLabel.translatesAutoresizingMaskIntoConstraints  = false
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        locationLabel.sizeToFit()
        distanceLabel.sizeToFit()
        episodeLabel.sizeToFit()
        summaryLabel.sizeToFit()
        playButton.sizeToFit()
        durationLabel.sizeToFit()
        self.sizeToFit()
    }
    
    func setupWithAnnotation(annotation: MapEpisodeAnnotation, forUserLocation location: CLLocation?) {
        let episode = annotation.episode!
        let podcast = episode.podcast
        
        self.locationLabel?.text = "The White House"
        let placeLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        if location != nil {
            let distance = location!.distanceFromLocation(placeLocation)
            self.distanceLabel.text = "\(distance)"
        }
        self.episodeLabel.text = "\(podcast.title) - \(episode.title)"
        if episode.duration != nil {
            self.durationLabel.text = Episode.durationAsString(durationInSeconds: episode.duration!)
        }
        if episode.summary != nil {
            self.summaryLabel.text = episode.summary!
        } else if episode.itunesSummary != nil {
            self.summaryLabel.text = episode.itunesSummary!
        } else if episode.itunesSubtitle != nil {
            self.summaryLabel.text = episode.itunesSubtitle!
        }
        
        //        self.canShowCallout = true
        
    }
}
