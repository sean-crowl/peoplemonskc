//
//  MapPin.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/7/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit
import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var person: Person?
    
    init(person: Person) {
        self.person = person
        if let lat = person.latitude, let long = person.longitude {
            self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
}
