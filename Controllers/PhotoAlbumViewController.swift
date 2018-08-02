//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by John Nolan on 6/27/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class photoAlbumViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var dataController: DataController!
    var photos: [Photo] = []
    var currentPin: Pin!
    var photosExist: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: populate collection view with photos that belong to selected pin
        
        //create fetch request to pull photos attached to current pin
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        
        //check if photos already exist in the pin or if it is new
        if photosExist {
            //TODO: load photos from persistent store
        } else {
            //pull photos from flickr using the coords from currentPin
            virtualTouristModel.sharedInstance().getPhotosForLocation(latitude: currentPin.latitude, longitude: currentPin.longitude) {(success, error, data) in
                if success {
                    for property in data {
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.imageData = property
                        self.photos.append(photo)
                    }
                    try? self.dataController.viewContext.save()
                }
                
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: "Default Action"), style: .default))
                    alert.message = error!
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
