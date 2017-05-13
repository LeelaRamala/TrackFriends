//
//  UniqueUserDetails.swift
//  TrackFriends
//
//  Copyright © 2017 Toms. All rights reserved.
//

import Foundation
import RealmSwift

class UniqueUserDetails: Object {
    dynamic var phone: String?
    dynamic var deviceID: String?
    dynamic var isRequestedForLocationAccess = false
    var latitude: Float?
    var longitude: Float?
    
    
    convenience init(withPhoneNumber number: String?, deviceID: String) {
        self.init()
        self.phone = number
        self.deviceID = deviceID
    }
    
    func updateCordinates(longitude: Float, latitude: Float) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

class Users: Object {
    let listOfUsers = List<UniqueUserDetails>()
    
    func updateUniqueUserForValue(number: String) {
        
        let phoneValue = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        
        for eachUniqueUser in listOfUsers {
            if eachUniqueUser.phone == phoneValue {
                eachUniqueUser.isRequestedForLocationAccess = true
                break
            }
        }
    }
}
