//
//  User.swift
//  Geocast
//
//  Created by Andrew Brown on 11/9/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import Foundation
       
class User : NSObject {
    
    private var subscriptions: [Podcast] = []
    
    class var sharedInstance: User {
        struct Singleton {
            static let instance = User()
        }
        return Singleton.instance
    }
    
    func subscribe(podcast: Podcast) -> Bool {
        if subscriptions.contains(podcast) {
            return false
        } else {
            subscriptions.append(podcast)
            return true
        }
    }
    
    func unsubscribe(podcast: Podcast) -> Bool {
        if subscriptions.contains(podcast) {
            let index = subscriptions.indexOf(podcast)
            subscriptions.removeAtIndex(index!)
            return true
        } else {
            return false
        }
    }
    
    func getSubscriptions() -> [Podcast]{
        return subscriptions
    }
}