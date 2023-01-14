//
//  ViewController.swift
//  MyLocations
//
//  Created by maxshikin on 13.01.2023.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var location : CLLocation?
    
    //MARK: - IBActionOutlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       updateLabels()
    }

    //MARK: - Actions
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus
       
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - LocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError - \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        location = newLocation
        updateLabels()
    }
    
        //MARK: - Helper Methods
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in settings",
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK",
                                        style: .default,
                                        handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = "Latitude"
            longtitudeLabel.text = "Longtitude"
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get my location' to start"
        }
    }
}

