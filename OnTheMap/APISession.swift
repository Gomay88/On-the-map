//
//  APISession.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/27/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

struct APIData {
    let scheme: String
    let host: String
    let path: String
    let domain: String
}

class APISession {
    let session: URLSession!
    let apiData: APIData
    
    init(apiData: APIData) {
        let configuration = URLSessionConfiguration.default
        
        self.session = URLSession(configuration: configuration)
        self.apiData = apiData
    }
    
    func makeRequestToURL(url: URL, method: HTTPMethod, headers: [String: String]? = nil, body: [String: AnyObject]? = nil, responseHandler: @escaping(Data?, Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                responseHandler(nil, error)
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 200 && statusCode > 299 {
                let userInfo = [
                    NSLocalizedDescriptionKey: "Error code != 2xx"
                ]
                let error = NSError(domain: "Session failed", code: statusCode, userInfo: userInfo)
                responseHandler(nil, error)
                return
            }
            
            responseHandler(data, nil)
        }
        task.resume()
    }
    
    func urlForMethod(_ method: String?, withPathExtension: String? = nil, parameters: [String:AnyObject]? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = apiData.scheme
        components.host = apiData.host
        components.path = apiData.path + (method ?? "") + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    func errorWithStatus(_ status: Int, description: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: apiData.domain, code: status, userInfo: userInfo)
    }
}
