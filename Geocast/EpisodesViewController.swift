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
        
        //1
        self.episodesTableView.estimatedRowHeight = 40.0
        //2
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        var feedUrl = podcast.feedUrl
        
        var urlString = NSURL(string: feedUrl)
        var rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(rssUrlRequest, queue: queue) {
            (response, data, error) -> Void in
            //3
            self.xmlParser = NSXMLParser(data: data)
            
            self.xmlParser.delegate = self
            
            self.xmlParser.shouldProcessNamespaces = true
            self.xmlParser.parse()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let playerViewController = segue.destinationViewController as? PlayerViewController {
            var episodeIndex = episodesTableView.indexPathForSelectedRow()!.row
            var detailEpisode = self.episodes[episodeIndex]
            playerViewController.episode = detailEpisode
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension EpisodesViewController: NSXMLParserDelegate {
    func parser(parser: NSXMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes attributeDict: [NSObject : AnyObject]){
            
            println("elementName: \(elementName)\nqualifiedName: \(qualifiedName)\nattributes: \(attributeDict)")
            
            currentParsedElement = qualifiedName!
            if currentParsedElement == nil {
                currentParsedElement = elementName
            }
            entryValue = ""
            if elementName == "item" {
                self.insideItem = true
            }
            if elementName == "content" {
                if let url = attributeDict["url"] as? String {
                    entryDictionary["mp3Url"] = url
                }
            }
            if elementName == "enclosure" {
                if let url = attributeDict["url"] as? String {
                    entryDictionary["mp3Url"] = url
                }
            }
            if contains(interestingElementNames, elementName) {
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
        })
    }
}

extension EpisodesViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            
            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("episodeCell")as? UITableViewCell
            
            if (nil == cell){
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "episodeCell")
            }
            cell!.textLabel?.text = episodes[indexPath.row].title
            cell!.textLabel?.numberOfLines = 0
            cell!.detailTextLabel?.text = episodes[indexPath.row].itunesSubtitle
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
    }
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            return episodes.count
    }
}
extension EpisodesViewController: UITableViewDelegate {
//    func tableView(tableView: UITableView,
//        didSelectRowAtIndexPath indexPath: NSIndexPath){
//            println(indexPath)
//            //            let detailsVC = DetailsViewController(nibName: "DetailsViewController", bundle: nil)
//            //            detailsVC.entryUrl = entriesArray[indexPath.row]["link"]
//            //            detailsVC.entryTitle = entriesArray[indexPath.row]["title"]
//            //            self.navigationController?.pushViewController(detailsVC, animated: true)
//    }
}