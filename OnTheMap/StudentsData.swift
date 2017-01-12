//
//  StudentsData.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/29/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import UIKit

class StudentsData: NSObject {
    
    var studentLocations: [StudentWithLocation]?
    var currentStudent: StudentWithLocation!
    
    override init() {
        super.init()
    }
    
    fileprivate static var sharedInstance = StudentsData()
    
    class func sharedData() -> StudentsData {
        return sharedInstance
    }
}
