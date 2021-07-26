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
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlickerClient.fetchPhotos(lat: latitude, lon: longitude)
        
        mapView.delegate = self

        manager = CLLocationManager() //instantiate
        manager.delegate = self // set the delegate
        
        print("\(latitude) ---- \(longitude)")
        var coordinate = CLLocationCoordinate2DMake(latitude, longitude)// set coordinate
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }


}

