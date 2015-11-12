//
//  Subscription.swift
//  Geocast
//
//  Created by Andrew Brown on 11/12/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import Foundation

class Subscription {
    let podcast: Podcast!
    let dateTime: String!
    init(podcast: Podcast, dateTime: String) {
        self.podcast = podcast
        self.dateTime = dateTime
    }
}
