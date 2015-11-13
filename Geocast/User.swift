//
//  User.swift
//  Geocast
//
//  Created by Andrew Brown on 11/9/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import Foundation
import Parse
       
class User : NSObject {
    
    private var subscriptions: [Podcast] = []
    private lazy var iTunesAPI : APIController = APIController(delegate: self)
    
    static var subscriptionUpdateKey = "subscriptionsWereUpdated!"
    
    class var sharedInstance: User {
        struct Singleton {
            static let instance = User()
        }
        return Singleton.instance
    }
    
    func subscribe(podcast: Podcast) -> Bool {
        print("\nSUBSCRIBING!\n\n")
        if subscriptions.contains(podcast) {
            return false
        } else {
            subscriptions.append(podcast)
            saveSubscriptionsLocally()
            return true
        }
    }
    
    func unsubscribe(podcast: Podcast) -> Bool {
        if subscriptions.contains(podcast) {
            print("subscriptions has length \(subscriptions.count)")
            let index = subscriptions.indexOf(podcast)
            subscriptions.removeAtIndex(index!)
            print("subscriptions has length \(subscriptions.count)")
            saveSubscriptionsLocally()
            return true
        } else {
            return false
        }
    }
    
    func getSubscriptions() -> [Podcast] {
        return subscriptions
    }
    
    func updateSubscriptionsInBackgroundWithTarget(target: AnyObject, selector: Selector) {
        
    }
    
    func updateSubscriptions() {

    }
    
    func isSubscribedTo(podcast: Podcast) -> Bool {
        return subscriptions.contains(podcast)
    }
    
    func saveSubscriptionsLocally() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(subscriptions, toFile: Podcast.ArchiveURL.path!)
        if isSuccessfulSave {
            print("saved podcasts locally")
        } else {
            print("failed to save podcasts locally")
        }
    }
    
    func loadLocalSubscriptions() -> [Podcast]? {
        if let localPodcasts = NSKeyedUnarchiver.unarchiveObjectWithFile(Podcast.ArchiveURL.path!) as? [Podcast] {
            for pc in localPodcasts {
                if !subscriptions.contains(pc) {
                    subscriptions.append(pc)
                }
             }
            print("loaded \(localPodcasts.count) from local storage")
            return localPodcasts
            
        } else {
            return nil
        }
    }
    
}


extension User: APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.subscriptions = Podcast.podcastsWithJSON(resultsArray).reverse()
            self.saveSubscriptionsLocally()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            print("about to post notification")
            NSNotificationCenter.defaultCenter().postNotificationName(User.subscriptionUpdateKey, object: self)
        })
    }
}
