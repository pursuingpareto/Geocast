//
//  LocationTagController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/17/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit

class TagLocationController: UITableViewController {
    var locations = [MKMapItem]()
    var searchController = UISearchController()
    var episode: Episode!
    
    var nameForLocation: String?
    var addressForLocation: String?
    var descriptionForTag: String?
    var locationToAdd: CLLocation?
    let locationManager = CLLocationManager()
    
    var tagManager = TagManager.sharedInstance
    
    // TODO make this user's location
    let initialLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for location or address"
            controller.dimsBackgroundDuringPresentation = false
            let cell = self.tableView.dequeueReusableCellWithIdentifier("searchLocationCell", forIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! SearchLocationCell
            controller.searchBar.bounds = cell.bounds
            controller.searchBar.searchBarStyle = UISearchBarStyle.Minimal
            
            cell.searchBar = controller.searchBar
            cell.addSubview(cell.searchBar)
            
//            controller.searchBar.sizeToFit()
            return controller
        })()
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.delegate = self

        let backButton = UIButton(type: .System)
        backButton.setTitle("Back", forState: .Normal)
        backButton.sizeToFit()
        backButton.bounds.size.height = 70
//        backButton.frame.origin = CGPointMake(10, 10)
        backButton.contentHorizontalAlignment = .Left
        backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        backButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        tableView.tableHeaderView = backButton
        
        print("searchController.searchBar is \(searchController.searchBar)")
        
//        searchController.dimsBackgroundDuringPresentation = false
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("searchLocationCell", forIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! SearchLocationCell
//        cell.searchBar = searchController.searchBar
//        
//        searchController.searchBar.sizeToFit()
//        tableView.tableHeaderView = searchController.searchBar
//        searchController.searchBar.sizeToFit()
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else {
            if searchController.active {
                print("telling tableview that there are \(locations.count) locations")
                return locations.count
            } else {
                return 1 // 1 for the TagDescriptionCell
            }
        }
        
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("addTagCell", forIndexPath: indexPath) as! AddTagCell
                cell.episodeLabel.text = "\(episode.podcast.title) - \(episode.title)"
                print(nameForLocation)
                if nameForLocation == nil {
                    print("NAME FOR LOCATION IS NILL")
                    cell.locationLabel.text = "Must add location"
                } else {
                    print("name for location is NOT nil")
                    cell.locationLabel.text = nameForLocation!
                }
//                cell.locationLabel.text = (nameForLocation != nil) ? nameForLocation! : "Must add location"
                cell.descriptionLabel.text = (descriptionForTag != nil) ? descriptionForTag! : "Must add description"
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("tagLocationButtonsCell", forIndexPath: indexPath) as! TagLocationButtonsCell
                // TODO : Wire up the button so it actually adds a tag.
                
                if nameForLocation != nil && descriptionForTag != nil && locationToAdd != nil {
                    cell.addTagButton.enabled = true
                } else {
                    cell.addTagButton.enabled = false
                }
                
                return cell
            }
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchLocationCell", forIndexPath: indexPath) as! SearchLocationCell
            cell.searchBar = searchController.searchBar
            if nameForLocation != nil {
//                cell.searchBar.text = nameForLocation
            }
            return cell
        } else  {
            if searchController.active {
                let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationCell
                print("indexPath is \(indexPath)")
                print("locations has count \(locations.count)")
                let location = locations[indexPath.row]
                let pm = location.placemark
                
                // get address
                let address = getAddress(fromPlacemark: pm)
                cell.addressLabel.text = address
                
                cell.nameLabel.text = getName(fromPlacemark: pm)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("tagDescriptionCell", forIndexPath: indexPath) as! TagDescriptionCell
                cell.textView.text = descriptionForTag
                cell.textView.delegate = self
                return cell
            }
        }
    }
    
    func getName(fromPlacemark pm: MKPlacemark) -> String? {
        var text: String!
        if let areaOfInterest = pm.areasOfInterest?.first {
            text = areaOfInterest
        } else {
            text = pm.name
        }
        return text
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Tag"
        } else if section == 1 {
            return "Add Location"
        } else {
            if searchController.active {
                return nil
            } else {
                return "Add Description"
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController.active && indexPath.section == 2 {
            let location = locations[indexPath.row]
            nameForLocation = getName(fromPlacemark: location.placemark)
            locationToAdd = location.placemark.location
            print("nameForLocation is \(nameForLocation)")
            addressForLocation = getAddress(fromPlacemark: location.placemark)
            print("addressForLocation is \(addressForLocation)")
            searchController.active = false
            searchController.searchBar.resignFirstResponder()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }else {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 100
            } else {
                return 44
            }
        }
        if indexPath.section == 1 {
            return 44
        } else {
            if searchController.active {
                return 66
            } else {
                return 88
            }
        }
    }
    
    func getAddress(fromPlacemark pm: MKPlacemark) -> String {
        var address: String = ""
        if let addressLines = pm.addressDictionary!["FormattedAddressLines"] as? [String]{
            for line in addressLines {
                address += "\(line) "
            }
            return address
        } else if pm.name != nil {
            return pm.name!
        } else {
            return ""
        }
    }
    
    func search(string: String) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchController.searchBar.text
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let location : CLLocation!
        if let loc = locationManager.location {
            location = loc
        } else {
            location = initialLocation
        }
        request.region = MKCoordinateRegion(center: initialLocation.coordinate, span:span)
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({
            (response: MKLocalSearchResponse?, error: NSError?) in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let response = response else {
                return
            }
            
            //            for item in ((response.mapItems) as [MKMapItem]) {
            //                print("Item name = \(item.name)")
            //                print("Latitude = \(item.placemark.location!.coordinate.latitude)")
            //                print("Longitude = \(item.placemark.location!.coordinate.longitude)")
            //            }
            self.locations = response.mapItems
            self.tableView.reloadData()
        })
    }
    @IBAction func addTagButtonPressed(sender: AnyObject) {
        let message = "This will tag \(episode.podcast.title): \(episode.title) with the location \(nameForLocation!)"
        let alertController = UIAlertController(title: "Confirm Location Tag", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert) in
        })
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Add tag", style: .Default, handler: {
            (alert) in
            self.tagManager.addTag(forEpisode: self.episode, atLocation: self.locationToAdd!, withName: self.nameForLocation!, withDescription: self.descriptionForTag!, withAddress: self.addressForLocation!)
            if let presenter = self.presentingViewController as? PlayerViewController {
                presenter.popupText = "Tag Added!"
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(confirmAction)
        
        
        self.presentViewController(alertController, animated: true, completion: {
            
        })
        
        print("about to add tag")
    }
}

extension TagLocationController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("updating search results...")
        locations.removeAll(keepCapacity: false)
        if let text = searchController.searchBar.text {
            print("text is \(text)")
            search(text)
        }
    }
}

extension TagLocationController: UISearchControllerDelegate {
    func didPresentSearchController(searchController: UISearchController) {
        searchController.active = true
//        tableView.reloadData()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchController.active = false
//        tableView.reloadData()
    }
    
}

extension TagLocationController: CLLocationManagerDelegate {
    
}

extension TagLocationController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            descriptionForTag = textView.text
            textView.resignFirstResponder()
            tableView.reloadData()
            return false
        } else {
            return true
        }
        
    }
}