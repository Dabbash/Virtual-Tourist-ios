//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 17/07/2021.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var centerAnnotation = MKPointAnnotation()
    var manager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        manager = CLLocationManager() //instantiate
        manager.delegate = self // set the delegate
        
        var lat = 24.731807006668262 // get lat
        var long = 54.822695406647966 // get long
        var coordinate = CLLocationCoordinate2DMake(lat, long)// set coordinate
        
        var latDelta:CLLocationDegrees = 0.01 // set delta
        var longDelta:CLLocationDegrees = 0.01 // set long
        var span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        var region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: true)
        centerAnnotation.coordinate = mapView.centerCoordinate
        self.mapView.addAnnotation(centerAnnotation)

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        centerAnnotation.coordinate = mapView.centerCoordinate;
    }


}

