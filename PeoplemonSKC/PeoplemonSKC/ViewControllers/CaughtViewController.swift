//
//  CaughtViewController.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/8/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit

class CaughtViewController: UITableViewController {
    var caught: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let person = Person()
        WebServices.shared.getObjects(person) { (objects, error) in
            if let objects = objects {
                self.caught = objects
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caught.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonTableViewCell.self)) as! PersonTableViewCell
        
        let person = caught[indexPath.row]
        cell.setupCell(person: person)
        
        return cell
    }
}
