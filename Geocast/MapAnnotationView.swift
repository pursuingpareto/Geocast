//
//  MapAnnotationView.swift
//  Geocast
//
//  Created by Andrew Brown on 11/14/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotationView: UIControl {
    
    var locationLabel: UILabel!
    var distanceLabel: UILabel!
    var episodeLabel: UILabel!
    var summaryLabel: UILabel!
    var playButton: UIButton!
    var durationLabel: UILabel!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        createSubviews()
        addAllSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        
        super.init(coder: aDecoder)
        createSubviews()
        addAllSubviews()
    }
    
    func createSubviews() {
        locationLabel = UILabel()
        distanceLabel = UILabel()
        episodeLabel = UILabel()
        summaryLabel = UILabel()
        playButton = UIButton()
        durationLabel = UILabel()
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        episodeLabel.translatesAutoresizingMaskIntoConstraints  = false
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        
//        self.translatesAutoresizingMaskIntoConstraints = true
//        
//        self.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var horizontalConstraint = NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8)
        self.addConstraint(horizontalConstraint)
//
//        horizontalConstraint = NSLayoutConstraint(item: episodeLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8)
//        self.addConstraint(horizontalConstraint)
//        
//        horizontalConstraint = NSLayoutConstraint(item: summaryLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8)
//        self.addConstraint(horizontalConstraint)
//        
        horizontalConstraint = NSLayoutConstraint(item: distanceLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: locationLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 8)
        self.addConstraint(horizontalConstraint)
//
        horizontalConstraint = NSLayoutConstraint(item: distanceLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -8)
        self.addConstraint(horizontalConstraint)
//
//        horizontalConstraint = NSLayoutConstraint(item: durationLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -8)
//        self.addConstraint(horizontalConstraint)
//        
//        horizontalConstraint = NSLayoutConstraint(item: durationLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: episodeLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 8)
//        self.addConstraint(horizontalConstraint)
//        
//        horizontalConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8)
//        self.addConstraint(horizontalConstraint)
//        
//        horizontalConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -8)
//        self.addConstraint(horizontalConstraint)
//        
//        horizontalConstraint = NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: distanceLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//        self.addConstraint(horizontalConstraint)
//        
//        horizontalConstraint = NSLayoutConstraint(item: episodeLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: durationLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//        self.addConstraint(horizontalConstraint)
//        
//        var verticalConstraint = NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 8)
//        self.addConstraint(verticalConstraint)
//        
//        verticalConstraint = NSLayoutConstraint(item: episodeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: locationLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8)
//        self.addConstraint(verticalConstraint)
//        
//        verticalConstraint = NSLayoutConstraint(item: summaryLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: episodeLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8)
//        self.addConstraint(verticalConstraint)
//        
//        verticalConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: summaryLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8)
//        self.addConstraint(verticalConstraint)
//        
//        verticalConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -8)
//        self.addConstraint(verticalConstraint)
        
        var widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 300)
        self.addConstraint(widthConstraint)
        
        var heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 150)
        self.addConstraint(heightConstraint)
//        
//        widthConstraint = NSLayoutConstraint(item: episodeLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 200)
        
        self.addConstraint(widthConstraint)
        locationLabel.sizeToFit()
        distanceLabel.sizeToFit()
        episodeLabel.sizeToFit()
        summaryLabel.sizeToFit()
        playButton.sizeToFit()
        durationLabel.sizeToFit()
        self.sizeToFit()
    }
    
    func addAllSubviews() {
        
        self.addSubview(locationLabel)
        self.addSubview(distanceLabel)
        self.addSubview(episodeLabel)
        self.addSubview(summaryLabel)
        self.addSubview(playButton)
        self.addSubview(durationLabel)
    }
    
    func adjustSizes() {
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
