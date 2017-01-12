//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/28/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import Foundation

class ParseClient {
    
    let apiSession: APISession
    
    init() {
        let apiData = APIData(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: "parse")
        apiSession = APISession(apiData: apiData)
    }
    
    static var sharedInstance = ParseClient()
    
    class func sharedClient() -> ParseClient {
        return sharedInstance
    }
    
    func makeRequestForParse(url: URL, method: HTTPMethod, body: [String: AnyObject]? = nil, headers: [String: String]? = nil, responseHandler: @escaping(_ jsonAsDictionary: [String: AnyObject]?,_ error: Error?) -> Void) {
        
        var fullHeaders = [
            HeaderKeys.ParseID: HeaderValues.ParseID,
            HeaderKeys.ParseKey: HeaderValues.ParseKey
        ]
        
        if let headers = headers {
            for (key, value) in headers {
                fullHeaders[key] = value
            }
        }
        
        apiSession.makeRequestToURL(url: url, method: method, headers: fullHeaders, body: body) { (data, error) in
            if let data = data {
                let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                responseHandler(jsonDictionary, nil)
            } else {
                responseHandler(nil, error)
            }
        }
    }
    
    func getStudentLocations(completionHandler: @escaping(_ studentsWithLocations: [StudentWithLocation]?, _ error: Error?) -> Void) {
        let parameters:[String:AnyObject] = ["order":"-updatedAt" as AnyObject]
        let url = apiSession.urlForMethod(Methods.StudentLocation, withPathExtension: nil, parameters: parameters)
        
        makeRequestForParse(url: url, method: .GET) { (jsonDictionary, error) in
            
            print(jsonDictionary!)
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary,
                let studentDictionaries = jsonDictionary["results"] as? [[String:AnyObject]] {
                completionHandler(StudentWithLocation.locationsFromDictionaries(studentDictionaries), nil)
                return
            }
            
            completionHandler(nil, self.apiSession.errorWithStatus(0, description: "Failed to login"))
        }
    }
    
    func getStudentLocationWithKey(_ userKey: String, completionHandler: @escaping (_ location: StudentWithLocation?, _ error: Error?) -> Void) {
        let url = apiSession.urlForMethod(Methods.StudentLocation, parameters: [
            "where": "{\"uniqueKey\":\"" + "\(userKey)" + "\"}" as AnyObject
        ])
        
        makeRequestForParse(url: url, method: .GET) { (jsonDictionary, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary,
                let studentDictionaries = jsonDictionary["results"] as? [[String:AnyObject]] {
                if studentDictionaries.count >= 1 {
                    completionHandler(StudentWithLocation(dictionary: studentDictionaries[0]), nil)
                    return
                }
            }
            
            completionHandler(nil, self.apiSession.errorWithStatus(0, description: "No key"))
        }
    }
    
    func postStudentLocation(_ student: StudentWithLocation, completionHandler: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        let url = apiSession.urlForMethod(Methods.StudentLocation)
        
        let headers = [
            HeaderKeys.ContentType: HeaderValues.ContentType
        ]
        
        let studentLocationBody: [String:AnyObject] = [
            BodyKeys.UniqueKey: student.student.key as AnyObject,
            BodyKeys.FirstName: student.student.firstName as AnyObject,
            BodyKeys.LastName: student.student.lastName as AnyObject,
            BodyKeys.MediaURL: student.student.url as AnyObject,
            BodyKeys.Latitude: student.location?.latitude as AnyObject,
            BodyKeys.Longitude: student.location?.longitude as AnyObject,
            BodyKeys.MapString: student.location?.map as AnyObject
        ]
        
        makeRequestForParse(url: url, method: .POST, body: studentLocationBody, headers: headers) { (jsonDictionary, error) in
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary,
                let _ = jsonDictionary[JSONResponseKeys.ObjectID] as? String {
                completionHandler(true, nil)
                return
            }
            
            completionHandler(false, self.apiSession.errorWithStatus(0, description: "Failed to create location"))
        }
    }
    
    func updateStudentLocationWithObjectID(studentwithLocation: StudentWithLocation, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        let url = apiSession.urlForMethod(Methods.StudentLocation, withPathExtension: "/\(studentwithLocation.objectId!)")
        
        let studentLocationBody: [String:AnyObject] = [
            BodyKeys.UniqueKey: studentwithLocation.student.key! as AnyObject,
            BodyKeys.FirstName: studentwithLocation.student.firstName as AnyObject,
            BodyKeys.LastName: studentwithLocation.student.lastName as AnyObject,
            BodyKeys.MapString: studentwithLocation.location!.map as AnyObject,
            BodyKeys.MediaURL: studentwithLocation.student.url as AnyObject,
            BodyKeys.Latitude: studentwithLocation.location!.latitude as AnyObject,
            BodyKeys.Longitude: studentwithLocation.location!.longitude as AnyObject
        ]
        
        let headers = [
            "Content-Type": "application/json"
        ]
        
        makeRequestForParse(url: url, method: .PUT, body: studentLocationBody, headers: headers) { (jsonDictionary, error) in
            
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary,
                let _ = jsonDictionary["updatedAt"] {
                completionHandler(true, nil)
                return
            }
            
            if let jsonDictionary = jsonDictionary,
                let error = jsonDictionary["error"] as? String {
                completionHandler(true, self.apiSession.errorWithStatus(0, description: error))
                return
            }
            
            completionHandler(false, self.apiSession.errorWithStatus(0, description: "Error uploading location"))
        }
    }
}
