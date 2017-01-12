//
//  Student.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/28/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

struct Student {
    
    let key: String?
    let firstName: String
    let lastName: String
    var url: String
    
    init(uniqueKey: String?, firstName: String, lastName: String, url: String) {
        self.key = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.url = url
    }
}
