//
//  PodcastSearchViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/8/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit

class PodcastSearchViewController: UITableViewController {
    
    
    @IBOutlet weak var resultsTableView: UITableView!
    var podcasts = [Podcast]()
    var filteredPodcasts = [Podcast]()
    var resultSearchController = UISearchController()
    lazy var iTunesAPI : APIController = APIController(delegate: self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        self.tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if (self.resultSearchController.active) {
            return self.filteredPodcasts.count
        }
        else {
            return self.podcasts.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("podcastCell", forIndexPath: indexPath) as! UITableViewCell
        
        // 3
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredPodcasts[indexPath.row].title
            
            return cell
        }
        else {
            cell.textLabel?.text = podcasts[indexPath.row].title
            
            return cell
        }
    }
    
}

extension PodcastSearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredPodcasts.removeAll(keepCapacity: false)
        iTunesAPI.searchPodcastsFor(searchController.searchBar.text)
    }
}

extension PodcastSearchViewController: APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary) {

        var resultsArray = results["results"] as! NSArray

        dispatch_async(dispatch_get_main_queue(), {
            self.filteredPodcasts = Podcast.podcastsWithJSON(resultsArray)
            self.tableView.reloadData()

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
    }
}