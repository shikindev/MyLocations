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
    var updatingLocation = false
    var lastLocationError : Error?
    
    var geoCoder = CLGeocoder()
    var placemark : CLPlacemark?
    var performingReceiveGeocoding = false
    var lastGeocodingError : Error?
    
    var timer: Timer?
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
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
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.startUpdatingLocation()
    }
    
    //MARK: - LocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError - \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        lastLocationError = nil
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("*** We are done")
            stopLocationManager()
            
            if distance > 0 {
                performingReceiveGeocoding = false
            }
        }
        updateLabels()
        
        if !performingReceiveGeocoding {
            print("*** Going to Geocode")
             performingReceiveGeocoding = true
            geoCoder.reverseGeocodeLocation(newLocation) { placemarks, error in
                self.lastGeocodingError = error
                if error == nil, let places = placemarks, !places.isEmpty {
                    self.placemark = places.last
                } else {
                    self.placemark = nil
                }
                self.performingReceiveGeocoding = false
                self.updateLabels()
                
            }
        } else if distance >  1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done")
                stopLocationManager()
                updateLabels()
            }
        }
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
            
            if let placemark = placemark {
                adressLabel.text = string(from: placemark)
            } else {
                if  performingReceiveGeocoding {
                    adressLabel.text = "Searching foe adress..."
                } else if lastGeocodingError != nil {
                    adressLabel.text = "Error finding adress"
                } else {
                    adressLabel.text = "No adress found"
                }
            }
        } else {
            latitudeLabel.text = "Latitude"
            longtitudeLabel.text = "Longtitude"
            tagButton.isHidden = true
//            messageLabel.text = "Tap 'Get my location' to start"
            let statusMessage : String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "LocationnService Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled()  {
                statusMessage = "LocationnService Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get my location' to start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let tmp = placemark.subThoroughfare {
            line1 += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            line1 += tmp
        }
        var line2 = ""
        if let tmp = placemark.locality {
            line2 += tmp + " "
        }
        if let tmp = placemark.administrativeArea {
            line2 += tmp + " "
        }
        if let tmp = placemark.postalCode {
            line2 += tmp
        }
        return line1 + "\n" + line2
    }
    
    //MARK: - Start/Stop location manager
    
    func startLocationManager () {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }

    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get my location", for: .normal)
        }
    }
    
    @objc func didTimeOut() {
        print("*** didTimeOut")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }

    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsVC
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
    }
    
    
    
}



