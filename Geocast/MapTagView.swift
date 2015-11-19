//
//  MapTagView.swift
//  Geocast
//
//  Created by Andrew Brown on 11/18/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit

class MapTagView: MKPinAnnotationView {
    
    var locationLabel: UILabel!
    var distanceLabel: UILabel!
    var episodeLabel: UILabel!
    var summaryLabel: UILabel!
    var playButton: UIButton!
    var durationLabel: UILabel!
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView:UIView? = super.hitTest(point, withEvent: event)
        if hitView != nil {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let rect: CGRect = self.bounds
        var isInside: Bool = CGRectContainsPoint(rect, point)
        if !isInside {
            for view in self.subviews {
                isInside = CGRectContainsPoint(view.frame, point)
                if isInside {
                    break
                }
            }
        }
        return isInside
    }
    
}
