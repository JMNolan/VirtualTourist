//
//  ViewController.swift
//  VirtualTourist
//
//  Created by John Nolan on 6/27/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import UIKit
import MapKit

class travelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: Properties
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Functions
    @IBAction func dropPin(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinates
        
        self.mapView.addAnnotation(annotation)
        
    }
}

