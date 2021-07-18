//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 18/07/2021.
//

import UIKit
import MapKit
import CoreLocation

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double?
    var logitude: Double?
    
    var latitudeZoom: Double?
    var logitudeZoom: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        let lat = UserDefaults.standard.double(forKey: "userLatitude")
        let long = UserDefaults.standard.double(forKey: "userLogitude")
        let latZoom = UserDefaults.standard.double(forKey: "userLatitudeDelta")
        let longZoom = UserDefaults.standard.double(forKey: "userLongitudeDelta")
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        
        print(latZoom)
        print(longZoom)
    
        mapView.setRegion(MKCoordinateRegion(center: location, latitudinalMeters: latZoom, longitudinalMeters: longZoom), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        //for normal lat and long
        latitude = mapView.centerCoordinate.latitude
        logitude = mapView.centerCoordinate.longitude
        
        //for zoom value of lat and long
        latitudeZoom = mapView.region.span.latitudeDelta
        logitudeZoom = mapView.region.span.longitudeDelta
        
        //save the value of lat and log and zooms value
        UserDefaults.standard.set(latitude, forKey: "userLatitude")
        UserDefaults.standard.set(logitude, forKey: "userLogitude")
        UserDefaults.standard.set(latitudeZoom, forKey: "userLatitudeDelta")
        UserDefaults.standard.set(logitudeZoom, forKey: "userLongitudeDelta")
        
        //normal print
        print(latitudeZoom)
        print(logitudeZoom)
        print("current coordinate \(latitude), \(logitude)")
                
    }
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.shared
            app.openURL(NSURL(string: annotationView.annotation?.subtitle! ?? "") as! URL)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
