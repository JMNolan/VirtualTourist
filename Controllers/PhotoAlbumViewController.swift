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
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var blockOperations: [BlockOperation] = []
    var currentPin: Pin!
    var photosExist: Bool!
    let itemSpacing: CGFloat = 9.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.dataSource = self
        reloadImages()
        
        //check if photos already exist in the pin or if it is new
        if !photosExist {
            pullNewPhotos()
        }
    }
    
    //get rid of fetched results controller instance when user leaves view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //pull photos from flickr using the coords from currentPin
    fileprivate func pullNewPhotos() {
        virtualTouristModel.sharedInstance().getPhotosForLocation(latitude: currentPin.latitude, longitude: currentPin.longitude) {(success, error, data) in
            if success {
                for property in data {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageData = property
                    self.currentPin.addToPhotos(photo)
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
    
    fileprivate func reloadImages() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
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
        if let count = fetchedResultsController.sections?[0].numberOfObjects {
            return count
        }else {
            return 0
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Setting cell with photo")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        let photoForCell = fetchedResultsController.object(at: indexPath)
        
        cell.cellImage.image = UIImage(data: photoForCell.imageData!)
        print(photoForCell.imageData!)
        
        return cell
    }
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        do{
            try dataController.viewContext.save()
        } catch {
            print("failed to save view context to persistent store")
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
