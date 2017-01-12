//
//  StudentWithLocation.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/28/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

struct StudentWithLocation {
    
    var objectId: String? = nil
    var student: Student
    var location: Location?
    
    init(dictionary: [String:AnyObject]) {
        
        objectId = dictionary[ParseClient.JSONResponseKeys.ObjectID] as? String
        
        let uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String
        let firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String ?? ""
        let lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String ?? ""
        let mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String ?? ""
        student = Student(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, url: mediaURL)
        
        let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double ?? 0.0
        let longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double ?? 0.0
        let mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String ?? ""
        location = Location(lat: latitude, long: longitude, map: mapString)
    }
    
    init(student: Student, location: Location? = nil) {
        self.student = student
        self.location = location
    }
    
    init(objectID: String?, student: Student, location: Location) {
        self.objectId = objectID
        self.student = student
        self.location = location
    }
    
    static func locationsFromDictionaries(_ dictionaries: [[String:AnyObject]]) -> [StudentWithLocation] {
        var studentWithLocations = [StudentWithLocation]()
        for studentDictionary in dictionaries {
            studentWithLocations.append(StudentWithLocation(dictionary: studentDictionary))
        }
        return studentWithLocations
    }
}
