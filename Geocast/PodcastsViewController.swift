//
//  PodcastsViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit

class PodcastsViewController: UIViewController {
    
    @IBOutlet weak var podcastsTableView: UITableView!
    
    var feedUrls : [String]!
    var podcastIds : [Int] = [152249110, 394775318]
    var podcasts = [Podcast]()
    lazy var iTunesAPI : APIController = APIController(delegate: self)
    
    override func viewDidLoad() {
        var addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPodcast:")
        self.navigationItem.rightBarButtonItem = addButton
        super.viewDidLoad()
        iTunesAPI.delegate = self
        //1
        self.podcastsTableView.dataSource = self
        self.podcastsTableView.delegate = self
        self.podcastsTableView.estimatedRowHeight = 40.0
        //2
        iTunesAPI.lookupMultiplePodcasts(podcastIds)
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
            var podcastIndex = podcastsTableView.indexPathForSelectedRow()!.row
            var detailPodcast = self.podcasts[podcastIndex]
            episodesViewController.podcast = detailPodcast
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
        
    }
}

extension PodcastsViewController: APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary) {

        var resultsArray = results["results"] as! NSArray

        dispatch_async(dispatch_get_main_queue(), {
            self.podcasts = Podcast.podcastsWithJSON(resultsArray)
            self.podcastsTableView.reloadData()

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
    }
}

extension PodcastsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            
            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("podcastCell") as? UITableViewCell
            
            if (nil == cell){
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "podcastCell")
            }
            


            
            let podcast = podcasts[indexPath.row]
            cell!.textLabel?.text = podcast.title
            
            
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