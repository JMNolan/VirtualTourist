//
//  MKPointAnnotation.swift
//  VirtualTourist
//
//  Created by John Nolan on 8/7/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import UIKit

class PinAnnotation: NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    var associatedPin: Pin!
}
