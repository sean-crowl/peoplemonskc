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
    @IBOutlet weak var avatarView: UIImageView!
    
    
    var person: Person!
    
    func setupCell(person: Person) {
        self.person = person
        
        nameLabel.text = person.userName
        if let image = Utils.imageFromString(imageString: person.avatarBase64) {
            avatarView.image = image
        } else {
            avatarView.image = UIImage(named: "question-mark")
        }
    }
}
