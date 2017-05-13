//
//  RealmHelper.swift
//  TrackFriends
//
//  Created by Ramala Srinivasulu, Leela on 5/13/17.
//  Copyright © 2017 Toms. All rights reserved.
//

import Foundation
import RealmSwift

struct Constants {
    #if os(OSX)
    static let syncHost = "127.0.0.1"
    #else
    static let syncHost = "169.254.249.89"
    #endif
    
    static let syncRealmPath = "TrackFriends"
    static let defaultListName = "My Tasks"
    static let defaultListID = "80EB1620-165B-4600-A1B1-D97032FDD9A0"
    
    static let syncServerURL = URL(string: "realm://\(syncHost):9080/~/\(syncRealmPath)")!
    static let syncAuthURL = URL(string: "http://\(syncHost):9080")!
    
    static let appID = Bundle.main.bundleIdentifier!
}


class RealmServer {
    
    var realm: Realm?
    var notificationToken: NotificationToken?
    
    func setupRealm() {
        let userName = "leela.jyothi91@gmail.com"
        let password = "Leela@13"
        
        SyncUser.logIn(with: .usernamePassword(username: userName, password: password, register: false), server: Constants.syncAuthURL) { user, error in
            guard let user = user else {
                fatalError(String(describing: error))
            }
            
            DispatchQueue.main.async {
                // Open Realm
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: Constants.syncServerURL)
                )
                
                self.realm = try! Realm(configuration: configuration)
            }
        }        
    }
    
    func writeData(data: UniqueUserDetails) {
        
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
    
    func fetchDataOf(type: UniqueUserDetails) {
        var listOfValues = [UniqueUserDetails]()
        
        if let values = self.realm?.objects(UniqueUserDetails.self).first {
            listOfValues = [values]
        }
        
        print("\(listOfValues)")
    }
    
    func registerNotification() {
        self.notificationToken = self.realm?.addNotificationBlock({ (notification, realm) in
            print("Write is successfull")
        })
    }
    
    deinit {
        notificationToken?.stop()
    }
}
