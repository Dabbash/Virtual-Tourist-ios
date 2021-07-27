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
    
    var pin: Pin!
    
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    var flickrPhotos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)

        sharedContext = appDelegate.persistentContainer.viewContext
        
        self.setFetchActive(true)
        
        FlickerClient.fetchFlickerData(lat: latitude, lon: longitude, completionHandler: { response, error in
            FlickerModel.photos = response
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.setFetchActive(false)
                if FlickerModel.photos.count == 0 {
                    self.labelFunc(isThereAnyContent: false)
                }
            }
        })
        
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
    
    
    func labelFunc(isThereAnyContent: Bool) {
        if isThereAnyContent {
            noContentLabel.isHidden = true
        } else {
            noContentLabel.isHidden = false
        }
    }
    
    func setFetchActive(_ fetchActive: Bool) {
        if fetchActive {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

}


// MARK: - UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
  
    // 2
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of photos: \(FlickerModel.photos.count)")
        return FlickerModel.photos.count
    }
  
    // 3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCellView", for: indexPath) as! CollectionViewCell
        
        let flickr = FlickerModel.photos[indexPath.row]
        
        FlickerClient.requestFlickerImage(server: flickr.server, id: flickr.id, secret: flickr.secret, completionHandler: {data, error in
            guard let data = data else {
                self.labelFunc(isThereAnyContent: false)
                return
            }
            
            let image = UIImage(data: data)
            cell.flickerImage.image = image
        })

        return cell
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
