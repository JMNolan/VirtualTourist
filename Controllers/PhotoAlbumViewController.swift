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

class photoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var dataController: DataController!
    var photos: [Photo] = []
    var currentPin: Pin!
    var photosExist: Bool!
    let itemSpacing: CGFloat = 9.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: populate collection view with photos that belong to selected pin
        
        imageCollectionView.dataSource = self
        
        //create fetch request to pull photos attached to current pin
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        
        //check if photos already exist in the pin or if it is new
        if photosExist {
            //execute fetch request to gather photos for selected pin and put them in the photos array
            if let results = try? dataController.viewContext.fetch(fetchRequest) {
                photos = results
                print(photos.count)
                self.imageCollectionView.reloadData()
            }
        } else {
            pullNewPhotos()
        }
    }
    
    //pull photos from flickr using the coords from currentPin
    fileprivate func pullNewPhotos() {
        virtualTouristModel.sharedInstance().getPhotosForLocation(latitude: currentPin.latitude, longitude: currentPin.longitude) {(success, error, data) in
            if success {
                for property in data {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageData = property
                    self.currentPin.addToPhotos(photo)
                    self.photos.append(photo)
                }
                try? self.dataController.viewContext.save()
                OperationQueue.main.addOperation({
                    self.imageCollectionView.reloadData()
                })
            }
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: "Default Action"), style: .default))
                alert.message = error!
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //refreshes images for a specific location by performing the pull again from flickr
    @IBAction func pullNewPhotoCollection(_ sender: Any) {
        //TODO: delete photos from local array, from persistent store, and
        self.photos = []
        for photo in photos {
            dataController.viewContext.delete(photo)
        }
        //pullNewPhotos()
        try? dataController.viewContext.save()
        //self.imageCollectionView.reloadData()
        
    }
    
    //function called when user taps an image in the collection view
    func deleteImage(at indexPath: IndexPath) {
        //TODO: delete image from array, delete image from persistent store, and reload data in collection view
    }
    
    //DataSourceMethods for collection view
    func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Setting cell with photo")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        let photoForCell = photos[(indexPath as NSIndexPath).row]
        
        cell.cellImage.image = UIImage(data: photoForCell.imageData!)
        print(photoForCell.imageData!)
        
        return cell
    }
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: Write code to delete photo from peristent store
        self.photos.remove(at: indexPath.item)
        let photoToDelete = photos[indexPath.item]
        dataController.viewContext.delete(photoToDelete)
        do{
            try dataController.viewContext.save()
        } catch {
            print("failed to save view context to persistent store")
        }
        collectionView.deleteItems(at: [indexPath])
    }
    
    //Set size of cells relative to the view size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((view.frame.width) - (3 * itemSpacing))/3
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    
}
