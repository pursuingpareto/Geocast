//
//  PodcastsViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit
import Parse
import DateTools

class PodcastsViewController: UITableViewController {
    
    
    @IBOutlet var podcastsTableView: UITableView!
    
    var feedUrls : [String]!
    var podcastIds: [Int] = []
    var user : User = User.sharedInstance
    var podcasts : [Podcast] = [Podcast]()
    var imageCache = [String : UIImage]()
    var customRefreshControl = UIRefreshControl()
   
    var testPodcast = Podcast(title: "Radiolab", thumbnailImageURL: "", largeImageURL: "", collectionId: 152249110, episodeCount: 144, feedUrl: "http://feeds.wnyc.org/radiolab", lastUpdated: "")
    
    lazy var iTunesAPI : APIController = APIController(delegate: self)
    
    func refreshPodcasts() {
        
        podcastIds.removeAll()
        
        for podcast in podcasts {
            podcastIds.append(podcast.collectionId)
        }
        
        if podcastIds.count > 0 {
            iTunesAPI.lookupMultiplePodcasts(podcastIds)
        }

        self.customRefreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        
        user.loadLocalSubscriptions()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userSubscriptionsUpdated", name: User.subscriptionUpdateKey, object: nil)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPodcast:")
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = editButtonItem()
        
        customRefreshControl.tintColor = UIColor.whiteColor()
        customRefreshControl.backgroundColor = UIColor(red:15/255, green: 65/255, blue: 79/255, alpha: 1)
        customRefreshControl.addTarget(self, action: "refreshPodcasts", forControlEvents: UIControlEvents.ValueChanged)
        podcastsTableView.addSubview(customRefreshControl)


        super.viewDidLoad()
        podcasts = user.getSubscriptions()
        
        
        iTunesAPI.delegate = self
        //1
        self.podcastsTableView.dataSource = self
        self.podcastsTableView.delegate = self
        self.podcastsTableView.estimatedRowHeight = 40.0
        //2
        
        for podcast in podcasts {
            podcastIds.append(podcast.collectionId)
        }
        
        if podcastIds.count > 0 {
            iTunesAPI.lookupMultiplePodcasts(podcastIds)
        }
    }
    
    func userSubscriptionsUpdated() {
        print("I heard the notification")
        self.podcasts = User.sharedInstance.getSubscriptions()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = user.getSubscriptions()

        if !Reachability.isConnectedToNetwork() {
            let alertController = UIAlertController(title: "Internet Offline", message: "Your internet appears to be offline.  Please check your connection and try again.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert) in
            })
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Okay", style: .Default, handler: {
                (alert) in
            })
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: {
                
            })
        } else {
            print("connected to network")
        }

        self.podcastsTableView.reloadData()
        
        
    }
    
    func addPodcast(sender: AnyObject) {
        performSegueWithIdentifier("searchSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let episodesViewController = segue.destinationViewController as? EpisodesViewController {
            let podcastIndex = podcastsTableView.indexPathForSelectedRow!.row
            let detailPodcast = self.podcasts[podcastIndex]
            episodesViewController.podcast = detailPodcast
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    func assignImage(toCellAtIndexPath indexPath: NSIndexPath, withUrl url:String) {

        var imgURL: NSURL = NSURL(string: url)!
        var image = self.imageCache[url]
        if image == nil {
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    image = UIImage(data: data!)
                    
                    // Store the image in to our cache
                    self.imageCache[url] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = self.podcastsTableView.cellForRowAtIndexPath(indexPath) as? PodcastCell {
                            cellToUpdate.podcastImageView?.image = image
                        }
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = self.podcastsTableView.cellForRowAtIndexPath(indexPath) as? PodcastCell {
                    cellToUpdate.podcastImageView?.image = image
                }
            })
        }
        
        // Download an NSData representation of the image at the URL
        
    }
}

extension PodcastsViewController: APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary) {

        let resultsArray = results["results"] as! NSArray

        dispatch_async(dispatch_get_main_queue(), {
            self.podcasts = Podcast.podcastsWithJSON(resultsArray)
            self.podcastsTableView.reloadData()

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
    }
}

extension PodcastsViewController {
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var finalCell: UITableViewCell?
            
            if podcasts.count == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("noPodcastsCell") as! NoPodcastsCell
                
                finalCell = cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("podcastCell")! as! PodcastCell
                
                let podcast = podcasts[indexPath.row]
                cell.titleLabel.text = podcast.title
                
                var df = NSDateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                
                let lastDate = df.dateFromString(podcast.lastUpdated!)
                
                if let lastDate = lastDate {
                    cell.detailLabel.text = "\(podcast.episodeCount!) Episodes, last \(lastDate.shortTimeAgoSinceNow())"
                }
                
                assignImage(toCellAtIndexPath: indexPath, withUrl: podcast.thumbnailImageURL)
                
                cell.textLabel?.numberOfLines = 0
                //            cell!.detailTextLabel?.text = podcast["description"]
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
                finalCell = cell
            }
            
            return finalCell!
    }
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            
            if podcasts.count == 0 {
                return 1
            }
            else {
                return podcasts.count
            }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Unsubscribe"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let pc = podcasts[indexPath.row]
            user.unsubscribe(pc)
            userSubscriptionsUpdated()
//            podcasts.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
