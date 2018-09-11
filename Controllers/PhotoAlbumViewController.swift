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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the region of the map
        let latDelta: Double = 1.0
        let lonDelta: Double = 1.0
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let centerCoordinate = CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        mapView.setRegion(region, animated: true)
        
        //add the current pin to the mapView
        let pin = PinAnnotation()
        pin.setCoordinate(newCoordinate: centerCoordinate)
        mapView.addAnnotation(pin)
        
        
        self.noImagesLabel.isHidden = true
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        reloadImages()
        
        //check if photos already exist in the pin or if it is new
        if !photosExist {
            pullNewPhotos()
        }
        OperationQueue.main.addOperation {
            self.imageCollectionView.reloadData()
        }
    }
    
    //get rid of fetched results controller instance when user leaves view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    //pull photos from flickr using the coords from currentPin
    fileprivate func pullNewPhotos() {
        virtualTouristModel.sharedInstance().getPhotosForLocation(latitude: currentPin.latitude, longitude: currentPin.longitude) {(success, error, URLs, photoCount, pageCount, currentPage) in
            if success {
                self.newCollectionButton.isEnabled = false
                OperationQueue.main.addOperation({
                    self.imageCollectionView.reloadData()
                })

                for url in URLs {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageURL = url
                    self.currentPin.addToPhotos(photo)
                }
                OperationQueue.main.addOperation {
                    try? self.dataController.viewContext.save()
                    self.imageCollectionView.reloadData()
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
    
    func downloadImage(using cell: CollectionViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.imageData {
            cell.activityIndicator.stopAnimating()
            cell.cellImage.image = UIImage(data: imageData)
        } else {
            if let imageUrl = photo.imageURL {
                cell.activityIndicator.startAnimating()
                let data = try? Data(contentsOf: imageUrl)
                        if let currentCell = collectionView.cellForItem(at: index) as? CollectionViewCell {
                            currentCell.cellImage.image = UIImage(data: data!)
                            cell.activityIndicator.stopAnimating()
                        }
                photo.imageData = data!
                        try? self.dataController.viewContext.save()
            }
        }
    }
    
    func reloadImages() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            self.imageCollectionView.reloadData()
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
    
    // MARK: CollectionView DataSource
    func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.photoCount {
            return count
        }else {
            self.noImagesLabel.isHidden = false
            return 0
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = self.fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        do{
            try dataController.viewContext.save()
        } catch {
            print("failed to save view context to persistent store")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celldentifier = "photoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celldentifier, for: indexPath) as! CollectionViewCell
        cell.cellImage.image = nil
        cell.activityIndicator.startAnimating()
        
        let photo = fetchedResultsController.object(at: indexPath)
        downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
        return cell
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

//    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("Setting cell with photo")
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
//        let photoForCell = fetchedResultsController.object(at: indexPath)

//        if self.placeHolderCount != nil {
//            cell.cellImage.image = #imageLiteral(resourceName: "VirtualTourist_512")
//            return cell
//        }
//
//        cell.cellImage.image = UIImage(data: photoForCell.imageData!)
//        return cell
//    }
