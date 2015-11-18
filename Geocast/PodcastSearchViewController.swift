//
//  PodcastSearchViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/8/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit

class PodcastSearchViewController: UITableViewController {
    
    
//    @IBOutlet weak var resultsTableView: UITableView!
    var podcasts = [Podcast]()
    var filteredPodcasts = [Podcast]()
    var resultSearchController = UISearchController()
    lazy var iTunesAPI : APIController = APIController(delegate: self)
    var user = User.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for Podcasts"
            controller.hidesNavigationBarDuringPresentation = false
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        navigationItem.title = "Search"
        resultSearchController.delegate = self
        print("SearchDisplayController is \(searchDisplayController)")
        
        self.tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        resultSearchController.searchBar.text = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        print("View did appear")
        super.viewDidAppear(animated)
        resultSearchController.active = true
        resultSearchController.searchBar.becomeFirstResponder()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("podcastCell", forIndexPath: indexPath) 
        
        // 3
        if (self.resultSearchController.active) {
//            if let filteredPodcast = filteredPodcasts[indexPath.row] {
//                cell.textLabel?.text = filteredPodcast.title
//            }
            cell.textLabel?.text = filteredPodcasts[indexPath.row].title
            
            return cell
        }
        else {
            cell.textLabel?.text = podcasts[indexPath.row].title
            
            return cell
        }
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let podcastIndex = indexPath.row
//        let podcast = filteredPodcasts[podcastIndex]
//        user.subscribe(podcast)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let episodesViewController = segue.destinationViewController as? EpisodesViewController {
            let podcast: Podcast!
            let indexPath = tableView.indexPathForSelectedRow!
            if (self.resultSearchController.active) {
                podcast = filteredPodcasts[indexPath.row]
            }
            else {
                podcast = podcasts[indexPath.row]
            }
            User.sharedInstance.saveEpisodesLocally([], forPodcast: podcast)
            episodesViewController.podcast = podcast
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
}

extension PodcastSearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredPodcasts.removeAll(keepCapacity: false)
        iTunesAPI.searchPodcastsFor(searchController.searchBar.text!)
    }
}

extension PodcastSearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(searchController: UISearchController) {
        print("Did present search controller")
        searchController.searchBar.becomeFirstResponder()
    }
}

extension PodcastSearchViewController: APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.filteredPodcasts = Podcast.podcastsWithJSON(resultsArray)
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}