//
//  LocationDetailsVC.swift
//  MyLocations
//
//  Created by maxshikin on 17.01.2023.
//

import Foundation
import UIKit

class LocationDetailsVC : UITableViewController  {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}
