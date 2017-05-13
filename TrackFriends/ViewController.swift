//
//  TFMapLocateMeViewController.swift
//  TrackFriends
//
//  Copyright © 2017 Toms. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts
import ContactsUI
import RealmSwift

class TFMapLocateMeViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate var locationManager = CLLocationManager()
    lazy var contactStore: CNContactStore = CNContactStore()
    var shouldContinuouslyShareLocation = false
    
     var appDelegate: AppDelegate? {
        get {
            return UIApplication.shared.delegate as? AppDelegate
        }
    }
    
    var bannerView: TFBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Location"
        
        NotificationCenter.default.addObserver(self, selector: #selector(TFMapLocateMeViewController.shareLocation), name:  NSNotification.Name(rawValue: "StartSharingYurLcoation"), object: nil)

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        if let yPosition = self.navigationController?.navigationBar.frame.maxY {
            let frame = CGRect(x: self.view.frame.origin.x, y: yPosition, width: self.view.bounds.width, height: 30)
            
            self.bannerView = TFBannerView(withFrame: frame, message: "Tap on Phone icon to enter your phone number. This is to help your friend to locate friends by asking permission")
            guard  let bannerView = self.bannerView else { return }
            
            self.view.addSubview(bannerView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TFMapLocateMeViewController.dismissBannerView))
            bannerView.addGestureRecognizer(tapGesture)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismissBannerView() {
        UIView.animate(withDuration: 1.2, delay: 0.1, options: .curveEaseOut, animations: {
            self.bannerView?.alpha = 0.0
        }) { (isCompleted) in
            self.bannerView?.isHidden = true
        }
    }
    
    @IBAction func presentActionSheetForNumber(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter Phone number", message: "Please enter your phone number.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "9876543210"
        }
        
        let alertAction = UIAlertAction(title: "Confirm Number", style: .destructive) { (action) in
            guard let textField =  alertController.textFields?.first else { return }
            self.syncEnteredNumberToRealm(number: textField.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showContactsList(_ sender: Any) {
           let contactViewController = CNContactPickerViewController()
        contactViewController.delegate = self
        self.present(contactViewController, animated: true, completion: nil)

    }
    
    // Pragma - server sync
    func syncEnteredNumberToRealm(number: String?) {
        if let value = number, let uniqueValue = UIDevice.current.identifierForVendor?.uuidString {
            
            DispatchQueue.global(qos: .background).async {
                let userDefaults = UserDefaults.standard
                userDefaults.set(uniqueValue, forKey: "uniqueID")
                userDefaults.synchronize()

            }
            
            let uniqueUserDetails = UniqueUserDetails(withPhoneNumber: value, deviceID: uniqueValue)
            
            if let appDelegate = self.appDelegate {
                
                if let users = appDelegate.realmServer?.fetchUsersData(), users.listOfUsers.isEmpty == false  {
                    
                    do {
                        try appDelegate.realmServer?.realm?.write {
                            users.listOfUsers.append(uniqueUserDetails)
                        }
                    }
                    catch {
                        
                    }

                }
                else {
                    let user = Users()
                    user.listOfUsers.append(uniqueUserDetails)
                    appDelegate.realmServer?.writeData(data: user)
                }
            }
        }
    }
}

extension TFMapLocateMeViewController: CNContactPickerDelegate {
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
         let value = contactProperty.contact.phoneNumbers[0].value.stringValue
            if let users = self.appDelegate?.realmServer?.fetchUsersData(), users.listOfUsers.isEmpty == false  {
               self.updateUniqueUserForValue(number: value, user: users)
            }
    }
    
    func updateUniqueUserForValue(number: String, user: Users) {
        let phoneValue = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        
        for eachUniqueUser in user.listOfUsers {
            if eachUniqueUser.phone == phoneValue {
                
                try! self.appDelegate?.realmServer?.realm?.write {
                    eachUniqueUser.isRequestedForLocationAccess = true
                     self.appDelegate?.realmServer?.registerNotification()
                }
                
                break
            }
        }

    }
    
    
    
}

extension TFMapLocateMeViewController: CLLocationManagerDelegate {
    
    func shareLocation() {
        
        let alertController = UIAlertController(title: "Sharing your location", message: "We're sharing your location", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            self.locationManager.startUpdatingLocation()
            self.shouldContinuouslyShareLocation = true

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.preferredAction = okAction

        self.present(alertController, animated: true, completion: nil)
    }
    
    func findUser() -> UniqueUserDetails? {
        
        let userDefaults = UserDefaults.standard
        let deviceID = userDefaults.value(forKey: "uniqueID") as? String

        
        if let users = self.appDelegate?.realmServer?.fetchUsersData(), users.listOfUsers.isEmpty == false  {
            for eachUser in users.listOfUsers {
                if eachUser.deviceID == deviceID {
                    return eachUser
                }
            }
        }
        
        return nil
    }

    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty == false {
            guard let finalLocation = locations.last else { return }
            
             print(finalLocation.horizontalAccuracy)
            
            if finalLocation.horizontalAccuracy < 2000 {
                
                if self.shouldContinuouslyShareLocation == false {
                    self.locationManager.stopUpdatingLocation()
                    let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                    let region = MKCoordinateRegion(center: finalLocation.coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
                else {
                    // Start updating latitude and logitude to server
                    
                    if let user = self.findUser() {
                        user.updateCordinates(longitude: Float(finalLocation.coordinate.longitude), latitude: Float(finalLocation.coordinate.latitude))
                    }
                }
            }
        }
    }
}

extension TFMapLocateMeViewController: MKMapViewDelegate {
     public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view: MKPinAnnotationView?
        
        if let annView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") as? MKPinAnnotationView {
            annView.annotation = annotation
            view = annView
        }
        else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5.0, y: -5.0)
            view = annotationView
        }
        
        view?.pinTintColor = MKPinAnnotationView.purplePinColor()
        return view
    }
}

class AnnotationView: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    
    init(title: String?, subTitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subTitle
        self.coordinate = coordinate
    }
}
