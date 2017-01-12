//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/27/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

extension UdacityClient {
    
    struct Common {
        static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
    }
    
    struct Components {
        static let Scheme = "https"
        static let Host = "www.udacity.com"
        static let Path = "/api"
    }
    
    struct Methods {
        static let Session = "/session"
        static let Users = "/users"
    }
    
    struct HeaderKeys {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    struct HeaderValues {
        static let JSON = "application/json"
    }
    
    struct HTTPBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let UserKey = "key"
        static let Status = "status"
        static let Session = "session"
        static let Error = "error"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}
