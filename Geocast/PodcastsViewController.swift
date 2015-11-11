//
//  PodcastsViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit
import Parse

class PodcastsViewController: UIViewController {
    
    @IBOutlet weak var podcastsTableView: UITableView!
    
    var feedUrls : [String]!
//    var podcastIds : [Int] = [152249110, 394775318]
    var podcastIds: [Int] = []
    var user : User = User.sharedInstance
    var podcasts : [Podcast] = [Podcast]()
    var imageCache = [String : UIImage]()
    
    var testPodcast = Podcast(title: "Radiolab", thumbnailImageURL: "", largeImageURL: "", collectionId: 152249110, episodeCount: 144, feedUrl: "http://feeds.wnyc.org/radiolab")
    
    lazy var iTunesAPI : APIController = APIController(delegate: self)
    
    override func viewDidLoad() {
        
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            print("Object has been saved.")
//        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPodcast:")
        self.navigationItem.rightBarButtonItem = addButton
        super.viewDidLoad()
        user.subscribe(testPodcast)
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        podcasts = user.getSubscriptions()

        self.podcastsTableView.reloadData()
    }
    
    func addPodcast(sender: AnyObject) {
        performSegueWithIdentifier("searchSegue", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PodcastsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var cell:PodcastCell! = tableView.dequeueReusableCellWithIdentifier("podcastCell")! as! PodcastCell
            
//            if (nil == cell){
//                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "podcastCell")
//            }
            
            let podcast = podcasts[indexPath.row]
            cell.titleLabel.text = podcast.title
            cell.detailLabel.text = "\(podcast.episodeCount) Episodes"
            assignImage(toCellAtIndexPath: indexPath, withUrl: podcast.thumbnailImageURL)
            
            cell!.textLabel?.numberOfLines = 0
//            cell!.detailTextLabel?.text = podcast["description"]
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
    }
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            return podcasts.count
    }
}

extension PodcastsViewController: UITableViewDelegate {

}