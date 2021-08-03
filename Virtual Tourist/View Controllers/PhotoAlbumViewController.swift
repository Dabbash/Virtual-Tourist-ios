//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 17/07/2021.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    var centerAnnotation = MKPointAnnotation()
    var manager:CLLocationManager!
    
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolBar: UIToolbar!

    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    var pin: Pin!
    var flickrPhotos: [Photo] = []
    
    var selectedIndex:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        
        //deleteAllRecords()

        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate  = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate

        if let result = try? sharedContext.fetch(fetchRequest) {
            flickrPhotos = result
    
            if flickrPhotos.count == 0 {
                setFetchActive(true)
                fetchDataFromFlicker()
            } else {
                labelFunc(isThereAnyContent: true)
            }
            
        } else {
            print("Could not fetch.")
        }
        
       
        
        mapView.delegate = self

        manager = CLLocationManager()
        manager.delegate = self
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: true)
        centerAnnotation.coordinate = mapView.centerCoordinate
        self.mapView.addAnnotation(centerAnnotation)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        sharedContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - MapView
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

    func fetchDataFromFlicker() {
        FlickerClient.fetchFlickerData(lat: latitude, lon: longitude, completionHandler: { [self] response, error in
            
            if response.isEmpty {
                self.labelFunc(isThereAnyContent: false)
                self.setFetchActive(false)
            }
            
            FlickerModel.photos = response
            
//            Create empty Photos to be replaced with placeholder images
            for _ in FlickerModel.photos {
                let newPhoto = Photo(context: sharedContext)
                flickrPhotos.append(newPhoto)
            }
            
            var indexNumber = 0
            
            for flickr in FlickerModel.photos {
                FlickerClient.requestFlickerImage(server: flickr.server, id: flickr.id, secret: flickr.secret, completionHandler: {data, error in
                    guard let data = data else {
                        return
                    }

                    let photo = Photo(context: self.sharedContext)
                    photo.title = flickr.id
                    photo.imageUrl = FlickerClient.Endpoint.photoURL(flickr.server, flickr.id, flickr.secret).stringValue

                    let image1 = UIImage(data: data)?.pngData()
                    photo.image = image1
                    photo.pin = self.pin
                    do {
                        try self.sharedContext.save()
                    } catch let error as NSError {
                      print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    DispatchQueue.main.async {
                        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                        let predicate  = NSPredicate(format: "pin == %@", pin)
                        fetchRequest.predicate = predicate

                        if let result = try? sharedContext.fetch(fetchRequest) {
//                            Replace placeholder Image with a downloaded image
                            flickrPhotos[indexNumber] = result[indexNumber]
                            indexNumber += 1
                            print(flickrPhotos.count)

                            self.collectionView.reloadData() {
//                                If this is the last photo disable loading
                                if result.count == FlickerModel.photos.count {
                                    setFetchActive(false)
                                }
                            }

                        } else {
                            print("Could not fetch.")
                        }
                        
                    }

                })
                
            }
            
            print("-----------Response from fetchDataFromFlicker Function----------------")
//            * This is not needed it already loads images in the code above *
//            DispatchQueue.main.async {
//
//                let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//                let predicate  = NSPredicate(format: "pin == %@", pin)
//                fetchRequest.predicate = predicate
//
//                if let result = try? sharedContext.fetch(fetchRequest) {
//                    flickrPhotos = result
//
//                    self.collectionView.reloadData()
//
//                    self.setFetchActive(false)
//
//                    print("-----------Check if there is value in Core Data----------------")
//                    print("Number of photos in Core Data \(flickrPhotos.count)")
//
//                    if FlickerModel.photos.count == 0 {
//                        self.labelFunc(isThereAnyContent: false)
//                    }
//                } else {
//                    print("Could not fetch.")
//                }
//
//            }
        })

//        self.collectionView.reloadData()
        

    }
    
    func labelFunc(isThereAnyContent: Bool) {
        if isThereAnyContent {
            noContentLabel.isHidden = true
            toolBar.isHidden = false
        } else {
            noContentLabel.isHidden = false
            toolBar.isHidden = true
        }
    }
    
    func setFetchActive(_ fetchActive: Bool) {
        if fetchActive {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
//    func selectedItemToDelete(indexPath: IndexPath) {
//
//        let photoToDelete = flickrPhotos[indexPath.row]
//
//        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//        let predicate  = NSPredicate(format: "title == %@", photoToDelete.title!)
//        fetchRequest.predicate = predicate
//
//        if let result = try? sharedContext.fetch(fetchRequest) {
//            flickrPhotos = result
//            for photo in flickrPhotos {
//                sharedContext.delete(photo)
//            }
//            try? sharedContext.save()
//        }
//
//        print("Photo left is: \(flickrPhotos.count)")
//        collectionView.reloadData()
//    }

    
    func deleteAllRecords() {
           //delete all data
        let context = appDelegate.persistentContainer.viewContext

           let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
           let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

           do {
               try context.execute(deleteRequest)
               try context.save()
           } catch {
               print ("There was an error")
           }
       }

    @IBAction func newCollectionButtonAction(_ sender: Any) {
        
        flickrPhotos = []
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate  = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate

        if let result = try? sharedContext.fetch(fetchRequest) {
            for photo in result {
                sharedContext.delete(photo)
                try? self.sharedContext.save()
            }
            
            collectionView.reloadData()
            
            setFetchActive(true)
            fetchDataFromFlicker()
  
        } else {
            print("Could not fetch.")
        }
        
    }
    
}


// MARK: - UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCellView", for: indexPath) as! CollectionViewCell
        
        //let flickr = FlickerModel.photos[indexPath.row]
        let flickr = flickrPhotos[indexPath.row]
        
        if let image = flickr.image {
            cell.flickerImage.image = UIImage(data: image)
        } else {
//            If image is empty use placeholder image
            cell.flickerImage.image = UIImage(named: "jk-placeholder-image")
        }

        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        sharedContext.delete(flickrPhotos[indexPath.row])
        try? self.sharedContext.save()
        flickrPhotos.remove(at: indexPath.row)
        
        collectionView.reloadData()
    }
    

}

// MARK: - Collection View Flow Layout Delegate
extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
  // 1
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let yourWidth = collectionView.bounds.width/3.0
        let yourHeight = yourWidth

        return CGSize(width: yourWidth, height: yourHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}




//MARK: - ReloadDataCompletion
extension UICollectionView {
//    Completion for CollectionView reloading data
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
            { _ in completion() }
    }
}
