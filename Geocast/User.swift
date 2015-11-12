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
                print("addUnique")
                PFUser.currentUser()!.addUniqueObject(pfPodcast, forKey: "subscriptions")
                print(PFUser.currentUser()?.isAuthenticated())
                PFUser.currentUser()!.saveInBackground()
                print("addedUnique")
            })
            return true
        }
    }
    
    func unsubscribe(podcast: Podcast) -> Bool {
        if subscriptions.contains(podcast) {
            let index = subscriptions.indexOf(podcast)
            subscriptions.removeAtIndex(index!)
            var query = PFQuery(className: "Podcast")
            query.whereKey("collectionId", equalTo: podcast.collectionId)
            query.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                var pfPodcast: PFObject!
                
                if error == nil && objects?.count > 0 {
                    // podcast exists
                    
                    PFUser.currentUser()!.removeObjectsInArray(objects!, forKey: "subscriptions")

                } else {
                    
                    print("ERROR REMOVING FROM PARSE")

                }
            })
            return true
        } else {
            return false
        }
    }
    
    func getSubscriptions() -> [Podcast]{
        return subscriptions
    }
}