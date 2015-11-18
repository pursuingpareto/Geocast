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

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        
        super.init(coder: aDecoder)
        
    }
    
    func makeOneTimeChanges() {
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 1
        playButton.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        playButton.layer.cornerRadius = 2
        playButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        playButton.layer.borderWidth = 1
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
        makeOneTimeChanges()
    }
    
    class func stringForDistance(distanceInMeters meters: CLLocationDistance) -> String {
        let miles = 0.000621371 * meters
        let feet = meters * 3.28084
        if feet < 1000 {
            return "\(Int(feet)) ft"
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%f mi", Int(miles))
        }
    }
    
    func setupWithAnnotation(annotation: MapEpisodeAnnotation, forUserLocation location: CLLocation?) {
        let episode = annotation.episode!
        let podcast = episode.podcast
        
        self.locationLabel?.text = "The White House"
        let placeLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        if location != nil {
            let meters = location!.distanceFromLocation(placeLocation)
            self.distanceLabel.text = MapPopupView.stringForDistance(distanceInMeters: meters)
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
