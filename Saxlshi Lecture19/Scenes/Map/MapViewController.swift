//
//  MapViewController.swift
//  Saxlshi Lecture19
//
//  Created by Giorgi Goginashvili on 1/19/23.
//

import UIKit
import MapKit


class MapViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    //MARK: - Properties
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //MARK: - Actions
    @IBAction func didTapDrawRoute(_ sender: UIButton) {
    }
    
    @IBAction func didTapClear(_ sender: UIButton) {
    }
    
    //MARK: - Methods
    
    
}

