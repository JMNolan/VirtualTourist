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

class photoAlbumViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
