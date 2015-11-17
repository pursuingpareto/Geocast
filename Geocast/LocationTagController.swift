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
    
    // TODO make this user's location
    let initialLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for location or address"
            controller.dimsBackgroundDuringPresentation = false
            let cell = self.tableView.dequeueReusableCellWithIdentifier("searchLocationCell", forIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! SearchLocationCell
            controller.searchBar.bounds = cell.bounds
            
            cell.searchBar = controller.searchBar
            cell.addSubview(cell.searchBar)
            
//            controller.searchBar.sizeToFit()
            return controller
        })()
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        
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
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if searchController.active {
                return locations.count
            } else {
                return 2 // 1 for the TagDescriptionCell and 1 for TagLocationButtons Cell
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchLocationCell", forIndexPath: indexPath) as! SearchLocationCell
            cell.searchBar = searchController.searchBar
            if nameForLocation != nil {
                cell.searchBar.text = nameForLocation
            }

            print("dequed searchLocationCell... searchController is \(searchController)")
            print("searchBar is... \(searchController.searchBar)")
            print("cell searchBar is \(cell.searchBar)")
            return cell
        } else {
            if searchController.active {
                let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationCell
                let location = locations[indexPath.row]
                let pm = location.placemark
                
                // get address
                let address = getAddress(fromPlacemark: pm)
                cell.addressLabel.text = address
                
                if let areaOfInterest = pm.areasOfInterest?.first {
                    cell.nameLabel.text = areaOfInterest
                } else {
                    cell.nameLabel.text = pm.name
                }
                return cell
                
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("tagDescriptionCell", forIndexPath: indexPath) as! TagDescriptionCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("tagLocationButtonsCell", forIndexPath: indexPath) as! TagLocationButtonsCell
                    // TODO : Wire up the button so it actually adds a tag.
                    return cell
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Add Location"
        } else {
            return "Add Description"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as? LocationCell{
            nameForLocation = cell.nameLabel.text
            addressForLocation = cell.addressLabel.text
            searchController.searchBar.resignFirstResponder()
            searchController.active = false
            tableView.reloadData()
        } else {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 66
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
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
}

extension TagLocationController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("updating search results...")
        if let text = searchController.searchBar.text {
            print("text is \(text)")
            search(text)
        }
    }
}

extension TagLocationController: UISearchControllerDelegate {
    func didPresentSearchController(searchController: UISearchController) {
        searchController.active = true
        tableView.reloadData()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchController.active = false
        tableView.reloadData()
    }
    
}