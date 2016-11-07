//
//  MapPin.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/7/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var phone: String?
    var url: URL?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, address: String?, phone: String?, url: URL?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = address
        self.phone = phone
        self.url = url
    }
}
