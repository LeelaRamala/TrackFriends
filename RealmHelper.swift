//
//  RealmHelper.swift
//  TrackFriends
//
//  Created by Ramala Srinivasulu, Leela on 5/13/17.
//  Copyright © 2017 Toms. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

struct Constants {
    #if os(OSX)
    static let syncHost = "127.0.0.1"
    #else
    static let syncHost = "169.254.93.56"
    #endif
    
    static let syncRealmPath = "TrackFriends"
    
    static let syncServerURL = URL(string: "realm://\(syncHost):9080/~/\(syncRealmPath)")!
    static let syncAuthURL = URL(string: "http://\(syncHost):9080")!
    
    static let appID = Bundle.main.bundleIdentifier!
}


class RealmServer {
    
    var realm: Realm?
    var notificationToken: NotificationToken?
    
    func setupRealm() {
        let userName = "sindhu.ramala01@gmail.com"
        let password = "Leela@13"
        
        
        let creds = SyncCredentials.usernamePassword(username: userName, password: password, register: false)
        
        SyncUser.logIn(with: creds, server: Constants.syncAuthURL, onCompletion: { (user, error) in
            
            guard let user = user else {
                                 fatalError(String(describing: error))
            }
            
            DispatchQueue.main.async {
                let config = SyncConfiguration.init(user: user, realmURL: Constants.syncServerURL)
                
                var defaultConfig = Realm.Configuration.defaultConfiguration
                defaultConfig.syncConfiguration = config
                
                self.realm = try! Realm(configuration: defaultConfig)                
            }
        })

        
//        
//        SyncUser.logIn(with: .usernamePassword(username: userName, password: password, register: false), server: Constants.syncAuthURL) { user, error in
//            guard let user = user else {
//                 fatalError(String(describing: error))
//            }
//            
//            DispatchQueue.main.async {
//                // Open Realm
//                let configuration = Realm.Configuration(
//                    syncConfiguration: SyncConfiguration(user: user, realmURL: Constants.syncServerURL)
//                )
//                
//                let creds = SyncCredentials.usernamePassword(username: userName, password: password, register: false)
//                
//                SyncUser.logIn(with: creds, server: Constants.syncServerURL, onCompletion: { (user, error) in
//                    
//                    if user != nil  {
//                    
//                       let config = SyncConfiguration.init(user: user!, realmURL: Constants.syncServerURL)
//                        
//                    }
//                })
//                
//                self.realm = try! Realm(configuration: configuration)
//            }
//        }        
    }
    
    func writeData(data: Users) {
        
        do {
            try self.realm?.write {
                self.realm!.add(data)
            }
            
            print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
            self.registerNotification()
        }
        catch {
            
        }
    }
    
    func fetchUsersData() -> Users? {
        
        if let value = self.realm?.objects(Users.self).first {
             return value
        }
        
        return nil
    }
    
    func registerNotification() {
        self.notificationToken = self.realm?.addNotificationBlock({ (notification, realm) in
            self.shouldShowNotifcationForLocationAccess(user: realm.objects(Users.self).first!)
        })
    }
    
    // TODO: Enable APNS
    
    func shouldShowNotifcationForLocationAccess(user: Users) {
        let userDefaults = UserDefaults.standard
        let deviceID = userDefaults.value(forKey: "uniqueID") as? String
        
        for eachUser in user.listOfUsers {
            if eachUser.deviceID == deviceID {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StartSharingYurLcoation"), object: nil)
                break;
            }
        }
    }
    
    
    deinit {
        notificationToken?.stop()
    }
    
    func deleteAllRealm() {
        try! self.realm?.write {
            self.realm?.deleteAll()
        }
    }
    
}
