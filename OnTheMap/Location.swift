//
//  Location.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/28/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import MapKit

struct Location {
    
    let latitude: Double
    let longitude: Double
    let map: String
    var coords: CLLocationCoordinate2D
    
    init(lat: Double, long: Double, map: String) {
        self.latitude = lat
        self.longitude = long
        self.map = map
        self.coords = CLLocationCoordinate2DMake(lat, long)
    }
}
