//
//  PodcastSummaryCell.swift
//  Geocast
//
//  Created by Andrew Brown on 11/13/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit

class PodcastSummaryCell: UITableViewCell {
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var podcastSummary: UILabel!
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var podcastTitle: UILabel!
    
    var podcast: Podcast!
    
//    @IBAction func subscribeButtonClicked(sender: AnyObject) {
//        if User.sharedInstance.isSubscribedTo(podcast!) {
//            // TODO add confirmation popup?
//            User.sharedInstance.unsubscribe(podcast)
//            subscribeButton.setTitle("Subscribe", forState: .Normal)
//        } else {
//            print("subscribe button pressed, attempting to subscribe...")
//            User.sharedInstance.subscribe((podcast)!)
//            subscribeButton.setTitle("Unsubscribe", forState: .Normal)
//        }
//    }
}
