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
            
            // try to get Podcast associated with annotation
            var query = PFQuery(className: "Podcast")
            query.whereKey("collectionId", equalTo: podcast.collectionId)
            query.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                var pfPodcast: PFObject!
                
                if error == nil && objects?.count > 0 {
                    // podcast exists
                    
                    print("PODCAST EXISTS")
                    
                    pfPodcast = objects![0]
                    
                    print(pfPodcast)
                } else {
                    
                    print("CREATING PODCAST IN PARSE")
                    pfPodcast = podcast.saveToParse()
                }

                PFUser.currentUser()!.addUniqueObject(pfPodcast, forKey: "subscriptions")
                PFUser.currentUser()!.saveInBackground()

            })
            return true
        }
    }
    
    func unsubscribe(podcast: Podcast) -> Bool {
        if subscriptions.contains(podcast) {
            print("subscriptions has length \(subscriptions.count)")
            let index = subscriptions.indexOf(podcast)
            subscriptions.removeAtIndex(index!)
            print("subscriptions has length \(subscriptions.count)")
            var query = PFQuery(className: "Podcast")
            query.whereKey("collectionId", equalTo: podcast.collectionId)
            query.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                var pfPodcast: PFObject!
                
                if error == nil && objects?.count > 0 {
                    // podcast exists
                    print("Removing PFPodcast...")
                    PFUser.currentUser()!.removeObjectsInArray(objects!, forKey: "subscriptions")
                    PFUser.currentUser()!.saveInBackground()
                    

                } else {
                    
                    print("ERROR REMOVING FROM PARSE")

                }
            })
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
        
        print("Updating subscriptions...")
        
        let query = PFQuery(className: "_User")
        query.includeKey("subscriptions")
        let user = query.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: {
            (result, error) in
            print("InsideBlock")
            let pfPodcasts : [PFObject] = result!["subscriptions"] as! [PFObject]
            print(pfPodcasts)
            var podcastIDs : [Int] = []
            for pfPodcast in pfPodcasts {
                print(pfPodcast)
                print("\n")
                var pcID = pfPodcast["collectionId"]
                
                print("id is \(pcID)")
                podcastIDs.append(pcID as! Int)
            }
            print(podcastIDs)
            self.iTunesAPI.lookupMultiplePodcasts(podcastIDs)

        })
    }
    
    func isSubscribedTo(podcast: Podcast) -> Bool {
        return subscriptions.contains(podcast)
    }
}


extension User: APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.subscriptions = Podcast.podcastsWithJSON(resultsArray)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            print("about to post notification")
            NSNotificationCenter.defaultCenter().postNotificationName(User.subscriptionUpdateKey, object: self)
        })
    }
}
