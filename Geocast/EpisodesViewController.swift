//
//  EpisodesViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit

class EpisodesViewController: UIViewController {
    
    @IBOutlet weak var episodesTableView: UITableView!
    
    var podcast: Podcast!
    var episodes: [Episode]! = Array()
    var imageCache = [String : UIImage]()
    var customRefreshControl = UIRefreshControl()
    
    var xmlParser: NSXMLParser!
    var entryTitle: String!
    var entryDescription: String!
    var entryLink: String!
    var insideItem: Bool = false
    var currentParsedElement:String! = String()
    var shouldParseCurrentElement = true
    var podcastDictionary: [String:String]! = Dictionary()
    var entryDictionary: [String:String]! = Dictionary()
    var entryValue: String = ""
    var entriesArray:[Dictionary <String, String> ]! = Array()
    let interestingElementNames = [
        "item",
        "title",
        "description",
        "image",
        "subtitle",
        "summary",
        "pubDate",
        "content",
        "thumbnail",
        "duration",
        "subtitle",
        "enclosure",
    ]
    
    var feedUrls : [NSURL?]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        customRefreshControl.tintColor = UIColor.whiteColor()
//        customRefreshControl.backgroundColor = UIColor(red:15/255, green: 65/255, blue: 79/255, alpha: 1)
//        customRefreshControl.addTarget(self, action: "refreshEpisodes", forControlEvents: UIControlEvents.ValueChanged)
//        episodesTableView.addSubview(customRefreshControl)

        //1
//        self.episodesTableView.estimatedRowHeight = 40.0
        //2
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        
        if let existingEpisodes = User.sharedInstance.loadLocalEpisodes(forPodcast: podcast) {
            episodes = existingEpisodes
        }
        
        queryEpisodes()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let existingEpisodes = User.sharedInstance.loadLocalEpisodes(forPodcast: podcast) {
            episodes = existingEpisodes
        }
        setTextForSubscribeButton()
        episodesTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        queryEpisodes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshEpisodes() {
        queryEpisodes()
        self.customRefreshControl.endRefreshing()
    }

    func queryEpisodes() {
        let feedUrl = podcast.feedUrl
        
        let urlString = NSURL(string: feedUrl)
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(rssUrlRequest, queue: queue) {
            (response, data, error) -> Void in
            //3
            if (error != nil) {
                print("oops, error")
            }
            else {
                if let data = data{
                    self.xmlParser = NSXMLParser(data: data)
                    
                    self.xmlParser.delegate = self
                    
                    self.xmlParser.shouldProcessNamespaces = true
                    self.xmlParser.parse()
                    
                }                
            }
        }

    }
    
    func setTextForSubscribeButton() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = episodesTableView.cellForRowAtIndexPath(indexPath) as? PodcastSummaryCell
        if User.sharedInstance.isSubscribedTo((podcast)!) {
            cell?.subscribeButton.setTitle("Unsubscribe", forState: .Normal)
        } else {
            cell?.subscribeButton.setTitle("Subscribe", forState: .Normal)
        }
    }
    
    @IBAction func subscribeButtonClicked(sender: UIButton) {
        if User.sharedInstance.isSubscribedTo((podcast)!) {
            // TODO add confirmation popup?
            
            let message = "Are you sure you want to unsubscribe from \(podcast.title)?"
            let alertController = UIAlertController(title: "Confirm Unsubscribe", message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert) in
            })
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Unsubscribe", style: .Default, handler: {
                (alert) in
                print("Confirming unsubscribe...")
                self.setTextForSubscribeButton()
                User.sharedInstance.unsubscribe((self.podcast)!)
            })
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: {
                
            })
        } else {
            print("subscribe button pressed, attempting to subscribe...")
            User.sharedInstance.subscribe((podcast)!)
        }
        setTextForSubscribeButton()
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
                        if let cellToUpdate = self.episodesTableView.cellForRowAtIndexPath(indexPath) as? PodcastSummaryCell {
                            cellToUpdate.podcastImageView?.image = image
                        }
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = self.episodesTableView.cellForRowAtIndexPath(indexPath) as? PodcastSummaryCell {
                    cellToUpdate.podcastImageView?.image = image
                }
            })
        }
        
        // Download an NSData representation of the image at the URL
        
    }
    
}

extension EpisodesViewController: NSXMLParserDelegate {
    func parser(parser: NSXMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes attributeDict: [String : String]){
            
            currentParsedElement = qualifiedName!
            if currentParsedElement == nil {
                currentParsedElement = elementName
            }
            entryValue = ""
            if elementName == "item" {
                self.insideItem = true
            }
            if elementName == "content" {
                var url = attributeDict["url"]
                if url != nil {
                    entryDictionary["mp3Url"] = url
                }
            }
            if elementName == "enclosure" {
                var url = attributeDict["url"]
                if url != nil {
                    entryDictionary["mp3Url"] = url
                }
            }
            if interestingElementNames.contains(elementName) {
                if insideItem {
                    shouldParseCurrentElement = true
                } else {
                    print("elementName: \(elementName)")
                    shouldParseCurrentElement = false
                }
            } else {
                shouldParseCurrentElement = false
            }
    }

    func parser(parser: NSXMLParser,
        foundCharacters string: String?){
//            if shouldParseCurrentElement {
                if string != nil {
                    var newString: String = "\(entryValue)\(string)"
                    entryValue = newString
                }
//            }
    }

    func parser(parser: NSXMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?){
            if shouldParseCurrentElement {
                entryDictionary[currentParsedElement] = entryValue
            } else {
                podcastDictionary[currentParsedElement] = entryValue
            }
            if elementName == "item" {
                self.insideItem = false
                entriesArray.append(entryDictionary)
                entryDictionary.removeAll(keepCapacity: true)
            }
    }
    //4
    func parserDidEndDocument(parser: NSXMLParser){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("dictionary \(self.podcastDictionary)")
            self.podcast.summary = self.podcastDictionary["description"]
            self.podcast.author = self.podcastDictionary["itunes:author"]
            self.podcast.lastUpdated = self.podcastDictionary["lastBuildDate"]
            var newEpisodes : [Episode] = []
            for entry in self.entriesArray {
                newEpisodes.append(Episode(parsedFeedData: entry, podcast:self.podcast))
            }
            
            if self.podcast.lastUpdated == nil {
                self.podcast.lastUpdated = newEpisodes.first?.pubDate
            }
            if User.sharedInstance.isSubscribedTo(self.podcast) {
                self.episodes = User.sharedInstance.updateLocalEpisodes(forPodcast: self.podcast, withEpisodes: newEpisodes)
            } else {
                self.episodes = newEpisodes
            }
            

            self.episodesTableView.reloadData()
//            self.podcastTitle.text = self.podcast.title
//            self.assignImage(self.podcast.thumbnailImageURL)
        })
    }
}

extension EpisodesViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("podcastSummaryCell")! as! PodcastSummaryCell
                cell.userInteractionEnabled = false
                cell.podcastTitle.text = podcast.title
                cell.podcastSummary.text = podcast.summary
                assignImage(toCellAtIndexPath: indexPath, withUrl: podcast.thumbnailImageURL)
                if User.sharedInstance.isSubscribedTo(podcast) {
                    cell.subscribeButton.setTitle("Unsubscribe", forState: .Normal)
                } else {
                    cell.subscribeButton.setTitle("Subscribe", forState: .Normal)
                }
                cell.podcast = podcast
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("episodeCell")! as! EpisodeCell
                let episode = episodes[indexPath.row - 1]
                
                //            if (nil == cell){
                //                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "episodeCell")
                //            }
                
                cell.episodeTitle.text = episode.title
                print("progress is \(episode.progress)")
                var minutes: Int!
                var seconds: Int!
                if episode.duration != nil {
                    // TODO - add hours support
                    minutes = episode.duration! / 60
                    seconds = episode.duration! - (minutes * 60)
                    let timePlayed = episode.approximateSecondsListenedToByUser
                    
                    cell.progressBar.setProgress(episode.progress, animated: false)
                    
                } else {
                    minutes = 10
                    seconds = 10
                }
                
                
                cell.duration.text = NSString(format: "%02d:%02d", minutes, seconds) as String
                
                let publicationDate = episode.pubDate
                
                cell.publicationDate.text = publicationDate.substringToIndex(publicationDate.startIndex.advancedBy(17))
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                return cell
            }
            
    }
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            return episodes.count + 1
    }
}
extension EpisodesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath){
            let ep = episodes[indexPath.row - 1]
            print("EPISODE IS \(ep.title)")
            PodcastPlayer.sharedInstance.episode = ep
            self.tabBarController?.selectedIndex = MainTabController.TabIndex.playerIndex.rawValue
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150
        } else {
            return 90
        }
    }
}