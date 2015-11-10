//
//  PodcastPlayer.swift
//  Geocast
//
//  Created by Andrew Brown on 11/10/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit
import AVFoundation

class PodcastPlayer: AVPlayer {
    class var sharedInstance: PodcastPlayer {
        struct Singleton {
            static let instance = PodcastPlayer()
        }
        return Singleton.instance
    }
}
