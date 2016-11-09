//
//  PersonTableViewCell.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/8/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var person: Person!
    
    func setupCell(person: Person) {
        self.person = person
        
        nameLabel.text = person.userName
    }
}
