//
//  chatTableViewController.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/9/23.
//

import UIKit

class chatCell: UITableViewCell {
    
    @IBOutlet weak var chatName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set custom background color
        self.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.5)
    }
}

class chatTableViewController: UITableViewController {
    
    @IBOutlet var chatTableView: UITableView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    var locations: [String] = ["New York", "Barcelona", "Budapest", "Rome", "Paris"]
    
    
    var interests: [String] = ["Night Life", "Museum and Culture", "Food", "Nature", "Shopping"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black, // Change this to your desired color
                .font: UIFont.systemFont(ofSize: 17) // Adjust the font size if needed
            ]
        editButton.setTitleTextAttributes(attributes, for: .normal)
        editButton.title = "Edit"
        tableView.backgroundColor = UIColor.systemPurple.withAlphaComponent(1)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Travel Chats"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return interests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! chatCell
        // Configure the cell...
        cell.chatName.text = interests[indexPath.row] + " @ " + locations[indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            interests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    
    
    @IBAction func toggleEdit(_ sender: UIBarButtonItem) {
        chatTableView.setEditing(!chatTableView.isEditing, animated: true)
        switch chatTableView.isEditing {
        case true:
            editButton.title = "Done"
        case false:
            editButton.title = "Edit"
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         let destVC = segue.destination as! chatDetailViewController
         let selectedRow = tableView.indexPathForSelectedRow?.row
         
         destVC.interestLabel = interests[selectedRow!]
     }

}
