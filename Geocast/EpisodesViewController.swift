//
//  EpisodesViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit

class EpisodesViewController: UIViewController {

    
    @IBOutlet weak var podcastTitle: UILabel!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var podcastImageView: UIImageView!
    
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
        
        customRefreshControl.tintColor = UIColor.whiteColor()
        customRefreshControl.backgroundColor = UIColor(red:15/255, green: 65/255, blue: 79/255, alpha: 1)
        customRefreshControl.addTarget(self, action: "refreshEpisodes", forControlEvents: UIControlEvents.ValueChanged)
        episodesTableView.addSubview(customRefreshControl)

        //1
        self.episodesTableView.estimatedRowHeight = 40.0
        //2
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        
        queryEpisodes()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setTextForSubscribeButton() 
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
            
            self.xmlParser = NSXMLParser(data: data!)
            
            self.xmlParser.delegate = self
            
            self.xmlParser.shouldProcessNamespaces = true
            self.xmlParser.parse()
        }

    }
    
    func setTextForSubscribeButton() {
        if User.sharedInstance.isSubscribedTo((podcast)!) {
            subscribeButton.setTitle("Unsubscribe", forState: .Normal)
        } else {
            subscribeButton.setTitle("Subscribe", forState: .Normal)
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
    
    func assignImage(url:String) {
        
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
                        self.podcastImageView.image = image
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.podcastImageView.image = image
            })
        }
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
                    shouldParseCurrentElement = false
                }
            } else {
                shouldParseCurrentElement = false
            }
    }

    func parser(parser: NSXMLParser,
        foundCharacters string: String?){
            if shouldParseCurrentElement {
                if string != nil {
                    entryValue += string!
                }
            }
    }

    func parser(parser: NSXMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?){
            if shouldParseCurrentElement {
                entryDictionary[currentParsedElement] = entryValue
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
            for entry in self.entriesArray {
                self.episodes.append(Episode(parsedFeedData: entry, podcast:self.podcast))
            }

            self.episodesTableView.reloadData()
            self.podcastTitle.text = self.podcast.title
            self.assignImage(self.podcast.thumbnailImageURL)
        })
    }
}

extension EpisodesViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("episodeCell")! as! EpisodeCell
            
//            if (nil == cell){
//                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "episodeCell")
//            }

            cell.episodeTitle.text = episodes[indexPath.row].title
            cell.duration.text = episodes[indexPath.row].duration
            
            let publicationDate = episodes[indexPath.row].pubDate
            
            cell.publicationDate.text = publicationDate.substringToIndex(publicationDate.startIndex.advancedBy(17))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
    }
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            return episodes.count
    }
}
extension EpisodesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath){
            let ep = episodes[indexPath.row]
            print("EPISODE IS \(ep.title)")
            PodcastPlayer.sharedInstance.episode = ep
            self.tabBarController?.selectedIndex = MainTabController.TabIndex.playerIndex.rawValue
    }
}