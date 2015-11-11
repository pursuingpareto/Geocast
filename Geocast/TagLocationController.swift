//
//  TagLocationController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/10/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit

class TagLocationController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    let initialLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
    let searchRadius: CLLocationDistance = 2000
    var searchController = UISearchController()
    var locations = [MKMapItem]()
    var tagManager = TagManager.sharedInstance
    var episode: Episode!

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, searchRadius * 2.0, searchRadius * 2.0)
//        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func search(string: String) {
        print("Searching for \(string)")
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
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
            
            for item in ((response.mapItems) as [MKMapItem]) {
                print("Item name = \(item.name)")
                print("Latitude = \(item.placemark.location!.coordinate.latitude)")
                print("Longitude = \(item.placemark.location!.coordinate.longitude)")
            }
            self.locations = response.mapItems
            self.tableView.reloadData()
        })
    }
    
}

extension TagLocationController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        search(searchText)
        dismissKeyboard()
    }
}

extension TagLocationController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = locations[indexPath.row]
        guard let loc = location.placemark.location else {
            print("No location for that...")
            return
        }
        print("about to add tag")
        tagManager.addTag(forEpisode: episode, atLocation: loc)
        performSegueWithIdentifier("unwindToPlayer", sender: self)
    }
}

extension TagLocationController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! LocationCell
        let location: MKMapItem = locations[indexPath.row]
        print("\nname is \(location.placemark.name)")
        print("addressDictionary is \(location.placemark.addressDictionary)")
        print("areasOfInterest is \(location.placemark.areasOfInterest)")
        print("locality is \(location.placemark.locality)")
        print("region is \(location.placemark.region)")
        print("thoroughfare is \(location.placemark.thoroughfare)")
        print("subthoroughfare is \(location.placemark.subThoroughfare)")
        print("administrativeArea is \(location.placemark.administrativeArea)")
        print("country is \(location.placemark.country)")
        print("description is \(location.placemark.description)\n")
        let pm = location.placemark
        
        // get address
        var address: String = ""
        if let addressLines = pm.addressDictionary!["FormattedAddressLines"] as? [String]{
            for line in addressLines {
                address += "\(line) "
            }
            cell.addressLabel.text = address
        } else {
            cell.addressLabel.text = pm.name
        }
        
        if let areaOfInterest = pm.areasOfInterest!.first {
            cell.nameLabel.text = areaOfInterest
        } else {
            cell.nameLabel.text = pm.name
        }
        
        cell.addressLabel.sizeToFit()
        
//        cell?.textLabel?.numberOfLines = 4
//        
//        
//        var name = ""
//        var addressNum = ""
//        var street = ""
//        var city = ""
//        var state = ""
//        var countryCode = ""
//        
//        if  pm.name != nil {
//            name = pm.name! + "\n"
//        }
//        
//        if  pm.subThoroughfare != nil {
//            addressNum = pm.subThoroughfare! + " "
//        }
//        
//        if pm.thoroughfare != nil {
//            street = pm.thoroughfare! + "\n"
//        }
//        
//        if pm.locality != nil {
//            city = pm.locality! + ", "
//        }
//        
//        if pm.administrativeArea != nil {
//            state = pm.administrativeArea! + ", "
//        } else {
//            var state = ""
//        }
//        
//        if pm.countryCode != nil {
//            countryCode = pm.countryCode!
//        }
//        
//        
//        let text = "\(name)\(addressNum)\(street)\(city)\(state)\(countryCode)"
//        cell?.textLabel?.text = text
        return cell
    }
}