//
//  TableViewController.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/8/23.
//

import Foundation
import UIKit

class TableViewController: UITableViewController{
    
    var trips: [String] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: "detailedChat", sender: self)
        }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailedChat" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selected = trips[indexPath.row]
                if let detailedViewController = segue.destination as? DetailedViewController {
                    print("")
                }
            }
        }
    }
}
