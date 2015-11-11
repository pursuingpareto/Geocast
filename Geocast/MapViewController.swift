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
    
    var episodesWithCoordinates: [(Episode!, CLLocationCoordinate2D)] = []
    
    var annotations: [MapEpisodeAnnotation] = []
    var tagManager = TagManager.sharedInstance

    var testCoordinate = CLLocationCoordinate2DMake(34.1561, -118.1319)
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 2000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        let initialLocation = CLLocation(latitude: testCoordinate.latitude, longitude: testCoordinate.longitude)
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
//            initialLocation = locationManager.location
        }
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func updateView() {
        PFGeoPoint.geoPointForCurrentLocationInBackground({
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil && geoPoint != nil {
                let currentLocation = CLLocation(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
                self.centerMapOnLocation(currentLocation)
                if let annotations = self.tagManager.getTagsFromParse(nearGeoPoint: geoPoint!) {
                    self.annotations = annotations
                    self.mapView.addAnnotations(self.annotations)
                }
            }
        })
    }
    
//    func calloutButtonClicked(sender: UIButton!) {
//        print("Callout Clicked!")
//        
//    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue : CLLocationCoordinate2D = manager.location!.coordinate
        centerMapOnLocation(manager.location!)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        print("Calling viewForAnnotation")
        if let annotation = annotation as? MapEpisodeAnnotation {
            let identifier = "tag"
            var view: MKPinAnnotationView
//            view.reuseIdentifier = identifier
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView { // 2
                print("  is a tag")
                dequeuedView.annotation = annotation
                view = dequeuedView
                view.image = annotation.image
                view.leftCalloutAccessoryView = UIImageView(image: annotation.image)
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let button: UIButton = UIButton(type: .DetailDisclosure) as UIButton
//                button.addTarget(self, action: "calloutButtonClicked:", forControlEvents: .TouchUpInside)
                
                view.rightCalloutAccessoryView = button
            } else {
                // 3
                print("  not a tag")
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.image = annotation.image
                view.leftCalloutAccessoryView = UIImageView(image: annotation.image)
                
                print(view.image?.size)
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                let button: UIButton = UIButton(type: .DetailDisclosure) as UIButton
//                button.addTarget(self, action: "calloutButtonClicked:", forControlEvents: .TouchUpInside)
                
                view.rightCalloutAccessoryView = button
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapEpisodeAnnotation {
            performSegueWithIdentifier("showPlayerFromMap", sender: annotation)
            print("Performing segue to player from map... sender is \(annotation)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let annotation = sender as? MapEpisodeAnnotation {
            if let destinationVC = segue.destinationViewController as? PlayerViewController {
                print("setting episode for destination VC")
                destinationVC.episode = annotation.episode!
                print("...episode set to \(annotation.episode?.description)")
            }
        }
        super.prepareForSegue(segue, sender: sender)
    }
}