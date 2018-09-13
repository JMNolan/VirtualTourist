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

class photoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var noImagesLabel: UITextField!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var blockOperations: [BlockOperation] = []
    var currentPin: Pin!
    var photosExist: Bool!
    let itemSpacing: CGFloat = 9.0
    var photoCount: Int!
    var placeHoldersNeeded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the region of the map
        let latDelta: Double = 1.0
        let lonDelta: Double = 1.0
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let centerCoordinate = CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        mapView.setRegion(region, animated: true)
        
        let scale = MKScaleView(mapView: mapView)
        scale.scaleVisibility = .visible
        mapView.addSubview(scale)
        
        //add the current pin to the mapView
        let pin = PinAnnotation()
        pin.setCoordinate(newCoordinate: centerCoordinate)
        mapView.addAnnotation(pin)
        
        DispatchQueue.main.async {
            self.noImagesLabel.isHidden = true
        }
        imageCollectionView.dataSource = self
        
        //check if photos already exist in the pin or if it is new
        if !photosExist {
            pullNewPhotos()
            try? dataController.viewContext.save()
        } else {
            reloadImages()
        }
    }
    
    //get rid of fetched results controller instance when user leaves view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    //pull photos from flickr using the coords from currentPin
    fileprivate func pullNewPhotos() {
        virtualTouristModel.sharedInstance().getPhotosForLocation(latitude: currentPin.latitude, longitude: currentPin.longitude) {(success, error, data, imageCount, totalPages, currentPage)  in
            if success {
                DispatchQueue.main.async {
                    self.newCollectionButton.isEnabled = false
                }
                self.photoCount = imageCount
                for url in data {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageURL = url
                    self.currentPin.addToPhotos(photo)
                }
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    print("pull photo save failed")
                }
            }
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: "Default Action"), style: .default))
                alert.message = error!
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //load images that have been previously downloaded
    fileprivate func reloadImages() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            self.photoCount = fetchedResultsController.fetchedObjects?.count
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //refreshes images for a specific location by performing the pull again from flickr
    @IBAction func pullNewPhotoCollection(_ sender: Any) {
        for photo in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photo)
        }
        pullNewPhotos()
    }
    
    //function for loading images that are stored or that are being downloaded
    private func downloadImage(using cell: CollectionViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
            if let imageData = photo.imageData {
                cell.activityIndicator.stopAnimating()
                cell.cellImage.image = UIImage(data: Data(referencing: imageData as NSData))
            } else {
                if let imageUrl = photo.imageURL {
                    cell.activityIndicator.startAnimating()
                    do {
                        let imageData = try Data(contentsOf: imageUrl)
                        let image = UIImage(data: imageData)
                        cell.cellImage.image = image
                        photo.imageData = imageData
                        cell.activityIndicator.stopAnimating()
                    } catch{
                        print("failed to download image from URL")
                    }
                    OperationQueue.main.addOperation {
                        try? self.dataController.viewContext.save()
                    }
                }
            }
        }
    
    // MARK: CollectionView DataSource
    func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.photoCount {
            print("\(count)")
            return count
        } else {
            DispatchQueue.main.async {
                self.noImagesLabel.isHidden = false
            }
            print("zero")
            return 0
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celldentifier = "photoCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celldentifier, for: indexPath) as! CollectionViewCell
            cell.cellImage.image = nil
            cell.activityIndicator.startAnimating()
        
            let photo = fetchedResultsController.object(at: indexPath)
            downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
            return cell
    }
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        self.photoCount = self.photoCount - 1
        OperationQueue.main.addOperation {
            try? self.dataController.viewContext.save()
        }
    }
    
    //Set size of cells relative to the view size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((view.frame.width) - (3 * itemSpacing))/3
        let height = width
        
        return CGSize(width: width, height: height)
    }
}

extension photoAlbumViewController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        imageCollectionView.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
            }, completion: {(completed) in
                
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: {
                self.imageCollectionView.insertItems(at: [newIndexPath!])
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: {
                self.imageCollectionView.deleteItems(at: [indexPath!])
            }))
        default:
            break
        }
    }
}
//USED
//func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let celldentifier = "PhotoCell"
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celldentifier, for: indexPath) as! PhotoCell
//    cell.imageView.image = nil
//    cell.activityIndicator.startAnimating()
//
//    let photo = fetchedResultsController.object(at: indexPath)
//    downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
//    return cell
//}
//


//private func downloadImage(using cell: PhotoCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
//    if let imageData = photo.image {
//        cell.activityIndicator.stopAnimating()
//        cell.imageView.image = UIImage(data: Data(referencing: imageData))
//    } else {
//        if let imageUrl = photo.imageUrl {
//            cell.activityIndicator.startAnimating()
//            FileDownloader.shared.downloadImage(imageUrl: imageUrl) { (data, error) in
//                if let _ = error {
//                    cell.activityIndicator.stopAnimating()
//                    return
//                } else if let data = data {
//                    if let currentCell = collectionView.cellForItem(at: index) as? PhotoCell {
//                        currentCell.imageView.image = UIImage(data: data)
//                        cell.activityIndicator.stopAnimating()
//                    }
//                    photo.image = NSData(data: data)
//                    DataController.shared.saveContext()
//                }
//            }
//        }
//    }
//}
