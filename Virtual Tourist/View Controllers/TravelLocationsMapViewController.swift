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

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double?
    var logitude: Double?
    
    var latitudeZoom: Double?
    var logitudeZoom: Double?
    
    var pins:[Pin] = []
    
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        mapView.delegate = self

        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        sharedContext = appDelegate.persistentContainer.viewContext
        
        fetchUserDefaultsDetailsForMap()
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(createNewAnnotation))
        uilpgr.minimumPressDuration = 0.25
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("--------------viewWillAppear----------------")
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        viewAllPins()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    fileprivate func fetchUserDefaultsDetailsForMap() {
        let lat = UserDefaults.standard.double(forKey: "userLatitude")
        let long = UserDefaults.standard.double(forKey: "userLogitude")
        let latZoom = UserDefaults.standard.double(forKey: "userLatitudeDelta")
        let longZoom = UserDefaults.standard.double(forKey: "userLongitudeDelta")
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        latitudeZoom = latZoom
        logitudeZoom = longZoom
        
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
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let ac = UIAlertController(title: "sdfghn", message: "wertgfhj", preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: nil))
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(ac, animated: true)
//    }
   
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
            
            //save the pin to core data
            save(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
        
        // Cancel the long press to make way for the next gesture
        sender.state = .cancelled
    }
    
    //when anotation is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        latitude = (view.annotation?.coordinate.latitude)!
        logitude = (view.annotation?.coordinate.longitude)!
        
        performSegue(withIdentifier: "showPhotoAlbumView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let photoAlbumVC = segue.destination as! PhotoAlbumViewController
        
        let annotation = mapView.selectedAnnotations[0]
        // getting the index of the selected annotation to set pin value in destination VC
        guard let indexPath = pins.firstIndex(where: { (pin) -> Bool in
            pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude
        }) else {
            return
        }
        
        photoAlbumVC.pin = pins[indexPath]
        photoAlbumVC.sharedContext = sharedContext
        
        photoAlbumVC.latitude = latitude!
        photoAlbumVC.longitude = logitude!

    }
    
    func viewAllPins() {
        
        print("--------------viewAllPins---------------")
        var annotations = [MKPointAnnotation]()
        
        //2
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin") //<Pin> Was <NSManagedObject>,, same aboive in pins array
          
          //3
        do {
            pins = try sharedContext.fetch(fetchRequest)
            print("number of annotation that added: \(pins.count)")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for pin in pins {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(pin.value(forKey: "latitude") as! Double)
            let long = CLLocationDegrees(pin.value(forKey: "longitude") as! Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(lat) -- \(long)"

            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
            self.mapView.addAnnotations(annotations)
            
        }
        
    }
    
    func save(latitude: Double, longitude: Double) {
      
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: sharedContext)!
      
        let pin = NSManagedObject(entity: entity, insertInto: sharedContext)
      
        pin.setValue(latitude, forKeyPath: "latitude")
        pin.setValue(longitude, forKeyPath: "longitude")
      
      do {
        try sharedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
}

