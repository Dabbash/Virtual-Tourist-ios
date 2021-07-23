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
    
    var pins:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

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
        
        //print("from viewDidLoad: latitude Zoom: \(latZoom)")
        //print("from viewDidLoad: longitude Zoom:\(longZoom)")
        
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
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let ac = UIAlertController(title: "sdfghn", message: "wertgfhj", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
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
        
        //try another solution
        save(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        // Cancel the long press to make way for the next gesture
        sender.state = .cancelled
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
        {
            if let annotationTitle = view.annotation?.title
            {
                print("User tapped on annotation with title: \(annotationTitle!)")
            }
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

    func viewAllPins() {
        
        print("--------------viewAllPins---------------")
        var annotations = [MKPointAnnotation]()
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
          
        let managedContext = appDelegate.persistentContainer.viewContext
          
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
          
          //3
        do {
            pins = try managedContext.fetch(fetchRequest)
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
            
            print(pin)
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
            self.mapView.addAnnotations(annotations)
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    func save(latitude: Double, longitude: Double) {
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
      
      // 1
        let managedContext = appDelegate.persistentContainer.viewContext
      
      // 2
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
      
        let pin = NSManagedObject(entity: entity, insertInto: managedContext)
      
      // 3
        pin.setValue(latitude, forKeyPath: "latitude")
        pin.setValue(longitude, forKeyPath: "longitude")
      
      // 4
      do {
        try managedContext.save()
        pins.append(pin)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    
    func removeSpecificAnnotation() {
        
        pins.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        print(pins.count)
    
        do {
            try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
}

