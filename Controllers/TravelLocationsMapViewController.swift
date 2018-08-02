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
    
    //MARK: Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            allPins = result
        }
        
        //TODO: make app transition to next view controller when existing pin is tapped
        
        //TODO: Add allPins to the map for the user to see
        for pin in allPins {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            self.mapView.addAnnotation(annotation)
        }
    }
    
    //MARK: Functions
    @IBAction func dropPin(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        //place pin on the map where user long presses
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        self.mapView.addAnnotation(annotation)
        
        //create Pin to be saved to persistent store
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        try? dataController.viewContext.save()
        
        //set the pin being dropped as the current pin
        self.currentPin = pin
        self.pinHasPhotos = false
        
        //Transition to photo album view controller
        performSegue(withIdentifier: "showPhotoCollection", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? photoAlbumViewController {
            vc.dataController = dataController
            vc.currentPin = self.currentPin
            vc.photosExist = self.pinHasPhotos
        }
    }
}

