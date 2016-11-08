//
//  ProfileInfoViewController.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/8/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController {
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UserStore.shared.user {
            fullNameLabel.text = user.fullName
            emailLabel.text = user.email

        // Do any additional setup after loading the view.
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
