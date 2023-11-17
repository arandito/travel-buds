//
//  chatDetailViewController.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/9/23.
//


import UIKit

class chatDetailViewController: UIViewController {
    
    @IBOutlet weak var interest: UILabel!
    var interestLabel: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemPurple.withAlphaComponent(1)


        self.interest.text = interestLabel
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

