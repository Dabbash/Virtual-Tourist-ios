//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 18/07/2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double?
    var logitude: Double?
    
    var latitudeZoom: Double?
    var logitudeZoom: Double?
    
    var dataController:DataController = DataController(modelName: "Virtual_Tourist")
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setUpFetchedResultController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        //***** need to a ask about sorting even if there is no table and only pin without creatinn date
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        fetchUserDefaultsDetailsForMap()
        
        // ??????? after adding this method and some lines in createNewAnnotation method to save the pins
        setUpFetchedResultController()
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(createNewAnnotation))
        uilpgr.minimumPressDuration = 0.25
        mapView.addGestureRecognizer(uilpgr)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //we need to tear down the fetchedResultsController when this view disappears
        fetchedResultsController = nil
    }
    
    fileprivate func fetchUserDefaultsDetailsForMap() {
        let lat = UserDefaults.standard.double(forKey: "userLatitude")
        let long = UserDefaults.standard.double(forKey: "userLogitude")
        let latZoom = UserDefaults.standard.double(forKey: "userLatitudeDelta")
        let longZoom = UserDefaults.standard.double(forKey: "userLongitudeDelta")
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        latitudeZoom = latZoom
        logitudeZoom = longZoom
        
        print("from viewDidLoad: latitude Zoom: \(latZoom)")
        print("from viewDidLoad: longitude Zoom:\(longZoom)")
        
        mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: latitudeZoom!, longitudeDelta: logitudeZoom!)), animated: false)
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
        //print(latitudeZoom)
        //print(logitudeZoom)
        //print("current coordinate \(latitude), \(logitude)")
                
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
   
    //Create new anotation
    @objc func createNewAnnotation(_ sender: UIGestureRecognizer) {
        
        let touchPoint = sender.location(in: self.mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let heldPoint = MKPointAnnotation()
        heldPoint.coordinate = coordinates

        if (sender.state == .began) {
            heldPoint.title = "Set Point"
            heldPoint.subtitle = String(format: "%.4f", coordinates.latitude) + "," + String(format: "%.4f", coordinates.longitude)
            mapView.addAnnotation(heldPoint)
        }
        
        //save pin to data model
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        try? dataController.viewContext.save()

        // Cancel the long press to make way for the next gesture
        sender.state = .cancelled
    }
    
    //when anotation is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.coordinate)
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
