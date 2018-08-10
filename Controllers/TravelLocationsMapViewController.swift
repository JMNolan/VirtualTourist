//
//  ViewController.swift
//  VirtualTourist
//
//  Created by John Nolan on 6/27/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class travelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    var dataController: DataController!
    var allPins: [Pin] = []
    var currentPin: Pin!
    var pinHasPhotos: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            allPins = result
        }
        
        //Add allPins to the map for the user to see
        for pin in allPins {
            let annotation = PinAnnotation()
            annotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
            annotation.associatedPin = pin
            self.mapView.addAnnotation(annotation)
        }
    }
    
    //MARK: Functions
    @IBAction func dropPin(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            print("Dropping pin")
            
            let location = sender.location(in: self.mapView)
            let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            //place pin on the map where user long presses
            let annotation = PinAnnotation()
            annotation.setCoordinate(newCoordinate: coordinates)
            self.mapView.addAnnotation(annotation)
            
            //create Pin to be saved to persistent store
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinates.latitude
            pin.longitude = coordinates.longitude
            try? dataController.viewContext.save()
            
            //set the pin being dropped as the current pin
            self.currentPin = pin
            annotation.associatedPin = pin
            self.pinHasPhotos = false
            
            //Transition to photo album view controller
            let photoAlbumVC = self.storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as! photoAlbumViewController
            photoAlbumVC.dataController = self.dataController
            photoAlbumVC.currentPin = self.currentPin
            photoAlbumVC.photosExist = self.pinHasPhotos
            navigationController?.pushViewController(photoAlbumVC, animated: true)
        }
    }
    
    //executes when user taps existing annotation on the map
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        print("standard delegate method")
        //pass necessary variables and transition to next view controller
        let photoAlbumVC = self.storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as! photoAlbumViewController
        let annotation = didSelect.annotation as! PinAnnotation
        photoAlbumVC.dataController = self.dataController
        photoAlbumVC.photosExist = true
        photoAlbumVC.currentPin = annotation.associatedPin
        print("I pressed a pin")
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
}

