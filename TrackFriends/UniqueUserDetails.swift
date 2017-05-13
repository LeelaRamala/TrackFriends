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
    
    convenience init(withPhoneNumber number: String?, deviceID: String) {
        self.init()
        self.phone = number
        self.deviceID = deviceID
    }
    
//    func syncToServer() {
//        
//        do {
//            let realm = try Realm()
//            
//            try realm.write {
//                 realm.add(self)
//            }
//            
//            print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
//        }
//        catch {
//            
//        }
//    }
    
}
