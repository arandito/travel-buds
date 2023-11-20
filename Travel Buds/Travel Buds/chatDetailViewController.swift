//
//  chatDetailViewController.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/9/23.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase

class chatDetailViewController: UIViewController {
    
    @IBOutlet weak var interest: UILabel!
    var interestLabel: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemPurple.withAlphaComponent(1)


        self.interest.text = interestLabel
        // Do any additional setup after loading the view.
    }
    
    //if you want to use the send and read message function of the firebasemanager
    //do FirebaseManager.shared.readMessages{{ messages in
    //for message in messages {
    // do stuff
    //  }
    //}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

