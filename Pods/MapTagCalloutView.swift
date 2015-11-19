//
//  MapTagCalloutView.swift
//  Pods
//
//  Created by Andrew Brown on 11/18/15.
//
//

import UIKit
import MapKit

class MapTagCallout : UIView {
    
    var locationLabel: UILabel!
    var distanceLabel: UILabel!
    var episodeLabel: UILabel!
    var summaryLabel: UILabel!
    var playButton: UIButton!
    var durationLabel: UILabel!
    
    let padding:CGFloat = 0
    
    var annotation: MapEpisodeAnnotation!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func prepareForDisplay() {
        backgroundColor = UIColor.whiteColor()
        userInteractionEnabled = true
        self.autoresizingMask =  [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin]
        createSubviews()
        setupLocationLabel()
        setupDistanceLabel()
        setupEpisodeLabel()
        setupDurationLabel()
        setupSummaryLabel()
//        setupPlayButton()
    }
    
    func setupSummaryLabel() {
        summaryLabel.text = annotation.tagDescription
        summaryLabel.numberOfLines = 5
        summaryLabel.sizeToFit()
        self.addSubview(summaryLabel)
    }
    
    func setupEpisodeLabel() {
        episodeLabel.text = annotation.episode?.title
        episodeLabel.numberOfLines = 2
        episodeLabel.sizeToFit()
        self.addSubview(episodeLabel)
    }
    
    func setupDistanceLabel(){
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        distanceLabel.text = "0.8 mi"
        distanceLabel.sizeToFit()
        self.addSubview(distanceLabel)
    }
    
    func setupDurationLabel() {
        durationLabel.text = "15:42"
        durationLabel.sizeToFit()
        self.addSubview(durationLabel)
    }
    
    override func updateConstraints() {
        print("UPDATE CONSTRAINTS CALLED")
        makeConstraints()
    }
    
    func makeConstraints() {
        let const1 = NSLayoutConstraint(
            item: locationLabel,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Leading, multiplier: 1.0,
            constant: padding)
        
        let const2 = NSLayoutConstraint(
            item: distanceLabel,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Trailing, multiplier: 1.0,
            constant: -padding)
        
        let const3 = NSLayoutConstraint(
            item: locationLabel,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Top, multiplier: 1.0,
            constant: padding)
        
        let const4 = NSLayoutConstraint(
            item: locationLabel,
            attribute: .CenterY ,
            relatedBy: .Equal,
            toItem: distanceLabel,
            attribute: .CenterY, multiplier: 1.0,
            constant: 0)
        
        let const5 = NSLayoutConstraint(
            item: locationLabel,
            attribute: .Right ,
            relatedBy: .LessThanOrEqual,
            toItem: distanceLabel,
            attribute: .Left, multiplier: 1.0,
            constant: -padding)
        
        let const6 = NSLayoutConstraint(
            item: episodeLabel,
            attribute: .Left ,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Left, multiplier: 1.0,
            constant: padding)
        
        let const7 = NSLayoutConstraint(
            item: episodeLabel,
            attribute: .Top ,
            relatedBy: .Equal,
            toItem: locationLabel,
            attribute: .Bottom, multiplier: 1.0,
            constant: padding)
        
        let const8 = NSLayoutConstraint(
            item: durationLabel,
            attribute: .CenterY ,
            relatedBy: .Equal,
            toItem: episodeLabel,
            attribute: .CenterY, multiplier: 1.0,
            constant: padding)
        
        let const9 = NSLayoutConstraint(
            item: durationLabel,
            attribute: .Right ,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Right, multiplier: 1.0,
            constant: -padding)
        
        let const10 = NSLayoutConstraint(
            item: episodeLabel,
            attribute: .Right ,
            relatedBy: .LessThanOrEqual,
            toItem: durationLabel,
            attribute: .Left, multiplier: 1.0,
            constant: -padding)
        
        let const11 = NSLayoutConstraint(
            item: summaryLabel,
            attribute: .Left ,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Left, multiplier: 1.0,
            constant: padding)
        
        let const12 = NSLayoutConstraint(
            item: summaryLabel,
            attribute: .Right ,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Right, multiplier: 1.0,
            constant: -padding)
        
        let const13 = NSLayoutConstraint(
            item: summaryLabel,
            attribute: .Top ,
            relatedBy: .Equal,
            toItem: episodeLabel,
            attribute: .Bottom, multiplier: 1.0,
            constant: padding)
        
        let const14 = NSLayoutConstraint(
            item: summaryLabel,
            attribute: .Bottom ,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Bottom, multiplier: 1.0,
            constant: -padding)
        
//        let const15 = NSLayoutConstraint(
//            item: self,
//            attribute: .Width ,
//            relatedBy: .GreaterThanOrEqual,
//            toItem: nil ,
//            attribute: .NotAnAttribute, multiplier: 1.0,
//            constant: 100)
//        
//        let const16 = NSLayoutConstraint(
//            item: self,
//            attribute: .Height ,
//            relatedBy: .GreaterThanOrEqual,
//            toItem: nil ,
//            attribute: .NotAnAttribute, multiplier: 1.0,
//            constant: 100)


//        let const4 = NSLayoutConstraint(item: locationLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -padding)
        
//        let const5 = NSLayoutConstraint(item: locationLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)
        
//        let const6 = NSLayoutConstraint(item: locationLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)
        
        NSLayoutConstraint.activateConstraints([const1, const2, const3, const4, const5, const6, const7, const8, const9, const10, const11, const12, const13, const14])
//        NSLayoutConstraint.activateConstraints([const1, const2, const3, const4, const5, const6])
//        resizeToFitSubviews()
//        layoutSubviews()
//        self.setNeedsLayout()
//        self.updateConstraints()
        super.updateConstraints()
    }

    func createSubviews() {
        locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        episodeLabel = UILabel()
        episodeLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel = UILabel()
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton = UIButton(type: .System)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLocationLabel() {
        locationLabel.text = annotation.locationName
        locationLabel.numberOfLines = 2
        locationLabel.sizeToFit()
//        locationLabel.frame.origin = CGPoint(x: 10, y: 10)
        self.addSubview(locationLabel)
//        self.sizeToFit()
    }
    
    func setupPlayButton() {
        playButton.setTitle("Play This Episode", forState: .Normal)
        playButton.sizeToFit()
//        playButton.frame.origin = CGPoint(x: 10, y: 10 + locationLabel.bounds.height + locationLabel.frame.origin.y)
        self.addSubview(playButton)
//        print("play button is \(playButton)")
//        self.sizeToFit()
    }
    
    func resizeToFitSubviews() {
        
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }
        
        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetInPlace(dx: -fix.x, dy: -fix.y)
        }
        
        frame.offsetInPlace(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
    }
    
}
