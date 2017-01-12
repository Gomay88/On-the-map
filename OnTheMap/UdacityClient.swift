//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/27/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import Foundation

class UdacityClient {
    
    let apiSession: APISession
    
    init() {
        let apiData = APIData(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: "Udacity")
        apiSession = APISession(apiData: apiData)
    }
    
    static var sharedInstance = UdacityClient()
    
    class func sharedClient() -> UdacityClient {
        return sharedInstance
    }
    
    func makeRequestForUdacity(url: URL, method: HTTPMethod, body: [String: AnyObject]? = nil, headers: [String: String]? = nil, responseHandler: @escaping(_ jsonAsDictionary: [String: AnyObject]?,_ error: Error?) -> Void) {
        
        var fullHeaders = [
            HeaderKeys.Accept: HeaderValues.JSON,
            HeaderKeys.ContentType: HeaderValues.JSON
        ]
        
        if let headers = headers {
            for (key, value) in headers {
                fullHeaders[key] = value
            }
        }
        
        apiSession.makeRequestToURL(url: url, method: method, headers: fullHeaders, body: body) { (data, error) in
            if let data = data {
                let jsonDictionary = try! JSONSerialization.jsonObject(with: data.subdata(in: Range(uncheckedBounds: (5, data.count))), options: .allowFragments) as! [String: AnyObject]
                responseHandler(jsonDictionary, nil)
            } else {
                responseHandler(nil, error)
            }
        }
    }
    
    func login(_ username: String, password: String, completionHandler: @escaping (_ userKey: String?, _ error: Error?) -> Void) {
        let url = apiSession.urlForMethod(Methods.Session)
        var body = [String: Any]()
        
        body[HTTPBodyKeys.Udacity] = [
            HTTPBodyKeys.Username: username,
            HTTPBodyKeys.Password: password
        ]
        
        makeRequestForUdacity(url: url, method: .POST, body: body as [String : AnyObject]?) { (jsonDictionary, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary {
                if let status = jsonDictionary[JSONResponseKeys.Status] as? Int,
                    let error = jsonDictionary[JSONResponseKeys.Error] as? String {
                    completionHandler(nil, self.apiSession.errorWithStatus(status, description: error))
                    return
                }
                
                if let account = jsonDictionary[JSONResponseKeys.Account] as? [String:AnyObject],
                    let key = account[JSONResponseKeys.UserKey] as? String {
                    completionHandler(key, nil)
                    return
                }
            }
            
            completionHandler(nil, self.apiSession.errorWithStatus(0, description: "Failed to login"))
        }
    }
    
    func logout(completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let url = apiSession.urlForMethod(Methods.Session)
        
        makeRequestForUdacity(url: url, method: .DELETE) { (jsonDictionary, error) in
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary , let _ = jsonDictionary[JSONResponseKeys.Session] as? [String: AnyObject] {
                completionHandler(true, nil)
                return
            }
            
            completionHandler(false, self.apiSession.errorWithStatus(0, description: "Failed to logout"))
        }
        
    }
    
    func studentData(_ userKey: String, completionHandler: @escaping (_ student: Student?, _ error: Error?) -> Void) {
        let url = apiSession.urlForMethod(Methods.Users, withPathExtension: "/\(userKey)")
        
        makeRequestForUdacity(url: url, method: .GET) { (jsonDictionary, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let jsonDictionary = jsonDictionary,
                let userDictionary = jsonDictionary[JSONResponseKeys.User] as? [String:AnyObject],
                let firstName = userDictionary[JSONResponseKeys.FirstName] as? String,
                let lastName = userDictionary[JSONResponseKeys.LastName] as? String{
                completionHandler(Student(uniqueKey: userKey, firstName: firstName, lastName: lastName, url: ""), nil)
                return
            }
            
            completionHandler(nil, self.apiSession.errorWithStatus(0, description: "Failed to retrieve data of student"))
        }
    }
}
