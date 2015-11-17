//
//  APIController.swift
//  MusicPlayer
//
//  Created by Jameson Quave on 9/16/14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController {
    
    var delegate: APIControllerProtocol

    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func getFromITunes(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            print("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            else {
                var err: NSError?
                
                if let data = data {
                    var jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    if(err != nil) {
                        // If there is an error parsing JSON, print it to the console
                        print("JSON Error \(err!.localizedDescription)")
                    }
                    let results: NSArray = jsonResult["results"] as! NSArray
                    
                    
                    self.delegate.didReceiveAPIResults(jsonResult) // THIS IS THE NEW LINE!!
                    
                }
                
            }
        })
        task.resume()
    }
    
    func searchItunesFor(searchTerm: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"

            getFromITunes(urlPath)
        }
    }
    
    func searchPodcastsFor(searchTerm: String) {
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=podcast"
            getFromITunes(urlPath)
        }

    }
    
    func lookupMultiplePodcasts(collectionIds: [Int]) {
        let id_string = collectionIds.map {($0.description)}.joinWithSeparator("," )
        print("Looking up \(id_string)")
        getFromITunes("https://itunes.apple.com/lookup?media=podcast&id=\(id_string)")
    }
    
    func lookupMultiplePodcasts(collectionIds: [Int], withCompletion completion: ([Podcast] -> Void)) {
        let id_string = collectionIds.map {($0.description)}.joinWithSeparator("," )
        print("Looking up \(id_string)")
        getFromITunes("https://itunes.apple.com/lookup?media=podcast&id=\(id_string)")

    }
    
    func lookupPodcast(collectionId: Int) {

        getFromITunes("https://itunes.apple.com/lookup?media=podcast&id=\(collectionId)")
    }
    
}