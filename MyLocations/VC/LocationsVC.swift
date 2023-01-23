//
//  LocationsVC.swift
//  MyLocations
//
//  Created by maxshikin on 20.01.2023.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class LocationsVC : UITableViewController {
    
    var managedObjectContext : NSManagedObjectContext!
//    var locations = [Location]()
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Locations")
        
        
//        fetchResultController.delegate = self
        return fetchedResultController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
//        let fetchRequest = NSFetchRequest<Location>()
//        let entity = Location.entity()
//        fetchRequest.entity = entity
//        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        do {
//            locations = try managedObjectContext.fetch(fetchRequest)
//        } catch {
//            fatalError("\(error)")
//        }
    }
    
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = fetchedResultController.object(at: indexPath)
        cell.configure(for: location)
        return cell
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsVC
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    //MARK: - Helper Methods
    
    func performFetch() {
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("\(error)")
        }
    }
    
//    deinit {
//        fetchedResultController.delegate = nil
//    }
}

extension LocationsVC : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** Controller will change content")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("***Insert")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** Delete")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .move:
            print("*** Move")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            print("*** Update")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
        @unknown default:
            print("Fatal error unnown type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            print("Move section")
        case .update:
            print("Update section")
        @unknown default:
            print("Unnown type section")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Did ChangeContent")
        tableView.endUpdates()
    }
}
