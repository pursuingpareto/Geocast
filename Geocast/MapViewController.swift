//
//  MapViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/9/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var episodesWithCoordinates: [(Episode!, CLLocationCoordinate2D)] = []
    
    var annotations: [MapEpisodeAnnotation] = []
    
    var testPodcast: Podcast = Podcast(title: "99% Invisible", thumbnailImageURL: "", largeImageURL: "", collectionId: 45, episodeCount: 150, feedUrl: "http://feeds.99percentinvisible.org/99percentinvisible")
    
    var testEpisode: Episode!
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
        
        testEpisode = Episode(parsedFeedData: [
            "title":"Bubble Houses",
            "mp3Url": "http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/99percentinvisible/cdn.99percentinvisible.org/wp-content/uploads/89-Bubble-Houses.mp3",
            "itunes:duration":"25:55",
            "pubDate":" Tue, 17 Sep 2013 07:17:49 +0000",
            "description":"description stuff",
            "itunes:summary":"summary stuff",
            "itunes:subtitle":"subtitle stuff"
            ], podcast: testPodcast)

        mapView.delegate = self
        episodesWithCoordinates += [(testEpisode, testCoordinate)]
        for (ep, coord) in episodesWithCoordinates {
            let mapEppAnnotation = MapEpisodeAnnotation(episode: ep, coordinate: coord)
            annotations.append(mapEppAnnotation)
            mapView.addAnnotation(mapEppAnnotation)
        }
        
        centerMapOnLocation(initialLocation)
        
    }
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
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
}