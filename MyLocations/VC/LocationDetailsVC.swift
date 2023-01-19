//
//  LocationDetailsVC.swift
//  MyLocations
//
//  Created by maxshikin on 17.01.2023.
//

import Foundation
import UIKit
import CoreLocation


private let dateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsVC : UITableViewController  {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    var categoryName = "No category"
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longtitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            adressLabel.text = string(from: placemark)
        } else {
            adressLabel.text = "*** No adress found"
        }
        dateLabel.text = format(date: Date())
        
        //Hide Keyboard
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        
        }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        guard let mainView = navigationController?.parent?.view else {return}
        let hudView = HudView.hud(inView: mainView, animated: true)
        hudView.text = "Tagged"
        
        afterDelay(0.6) {
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
//            hudView.hide()
//            self.navigationController?.popViewController(animated: true)
//        }
////        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerVC
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    //MARK: - Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
        }
        if let tmp = placemark.locality {
            text += tmp + ", "
        }
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
        }
        if let tmp = placemark.postalCode {
            text += tmp + ", "
        }
        if let tmp = placemark.country {
            text += tmp
        }
        return text
    }
    
    func format (date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerVC
            controller.selectedCategoryName = categoryName
        }
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
           return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
}
