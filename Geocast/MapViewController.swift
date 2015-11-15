//
//  MapViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/9/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapViewController: UIViewController {
    
    @IBOutlet weak var popupView: MapPopupView!
    var episodesWithCoordinates: [(Episode!, CLLocationCoordinate2D)] = []
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var redoSearchButton: UIButton!
    var annotations: [MapEpisodeAnnotation] = []
    var tagManager = TagManager.sharedInstance
    @IBOutlet var tableView: UITableView!
    var testCoordinate = CLLocationCoordinate2DMake(34.1561, -118.1319)
    let locationManager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 2000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        popupView.hidden = true

        tableView.hidden = true
        tableView.dataSource = self
        tableView.frame = mapView.frame
        tableView.delegate = self

        view.bringSubviewToFront(mapView)
        view.sendSubviewToBack(tableView)
        
        let initialLocation = CLLocation(latitude: testCoordinate.latitude, longitude: testCoordinate.longitude)
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
        }
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            tableView.hidden = true
            mapView.hidden = false
        case 1:
            tableView.reloadData()
            tableView.hidden  = false
            mapView.hidden = true
        default:
            break; 
        }
    }
    
    @IBAction func redoSearchInArea(sender: UIButton) {

        let location = mapView.region.center

        let geoPoint: PFGeoPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        if let annotations = self.tagManager.getTagsFromParse(nearGeoPoint: geoPoint) {
            self.annotations = annotations
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    func updateView() {
        print("Updating view")
        PFGeoPoint.geoPointForCurrentLocationInBackground({
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            print(geoPoint)
            print("error is \(error)")
            if geoPoint != nil {
                let currentLocation = CLLocation(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
                self.centerMapOnLocation(currentLocation)
                print("attempting to get annotations")
                if let annotations = self.tagManager.getTagsFromParse(nearGeoPoint: geoPoint!) {
                    self.annotations = annotations

                    self.mapView.addAnnotations(self.annotations)
                }
            }
        })
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue : CLLocationCoordinate2D = manager.location!.coordinate
        centerMapOnLocation(manager.location!)
    }
}

extension MapViewController: MKMapViewDelegate {
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        if let annotation = annotation as? MapEpisodeAnnotation {
//            var view: MapAnnotationView
//            let identifier = "mapAnnotation"
//            if let dequedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MapAnnotationView{
//                view = dequedView
//                view.setupWithAnnotation(annotation, forUserLocation: locationManager.location)
//            } else {
//                view = MapAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.setupWithAnnotation(annotation, forUserLocation: locationManager.location)
//            }
//            return view
//        }
//        return nil
//    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        if let annotation = annotation as? MapEpisodeAnnotation {
            let identifier = "tag"
            var view: MKPinAnnotationView
//            view.reuseIdentifier = identifier
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
                view.canShowCallout = false
//                view.canShowCallout = true

//                view.image = annotation.image
//                view.leftCalloutAccessoryView = UIImageView(image: annotation.image)
                let annotationView = MapAnnotationView()
                annotationView.setupWithAnnotation(annotation, forUserLocation: locationManager.location)
                annotationView.setupConstraints()
                view.leftCalloutAccessoryView = annotationView
                view.calloutOffset = CGPoint(x: -5, y: 5)
//                let button: UIButton = UIButton(type: .DetailDisclosure) as UIButton
//                view.rightCalloutAccessoryView = button
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                //                view.canShowCallout = true
//                view.image = annotation.image
//                view.leftCalloutAccessoryView = UIImageView(image: annotation.image)
                
                let annotationView = MapAnnotationView()
                annotationView.setupWithAnnotation(annotation, forUserLocation: locationManager.location)
                annotationView.setupConstraints()
                view.leftCalloutAccessoryView = annotationView

                view.calloutOffset = CGPoint(x: -5, y: 5)
//                let button: UIButton = UIButton(type: .DetailDisclosure) as UIButton
//                view.rightCalloutAccessoryView = button
            }
            print("LEFT CALLOUT IS \(view.leftCalloutAccessoryView)")
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapEpisodeAnnotation {
            PodcastPlayer.sharedInstance.episode = annotation.episode
            self.tabBarController?.selectedIndex = MainTabController.TabIndex.playerIndex.rawValue
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("DID SELECT ANNOTATION VIEW")
//        popupView.hidden = false
        popupView.setupConstraints()
        view.addSubview(popupView)
        view.bringSubviewToFront(popupView)

        popupView.setupWithAnnotation(view.annotation as! MapEpisodeAnnotation, forUserLocation: locationManager.location)
    }

}

extension MapViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let annotation = annotations[indexPath.row]
        let episode = annotation.episode
        let coordinate = annotation.coordinate
        let currentPosition = locationManager.location
        let distance = currentPosition?.distanceFromLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath)
        cell.textLabel!.text = "\(episode!.title): \(distance)"
        print(cell.textLabel!.text)
        return cell
    }
}

extension MapViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let annotation = annotations[indexPath.row]
        PodcastPlayer.sharedInstance.episode = annotation.episode
        self.tabBarController?.selectedIndex = MainTabController.TabIndex.playerIndex.rawValue
    }
}