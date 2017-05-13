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

class TFMapLocateMeViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate var locationManager = CLLocationManager()
    lazy var contactStore: CNContactStore = CNContactStore()
    var bannerView: TFBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Location"

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add banner to indicate message
        if let yPosition = self.navigationController?.navigationBar.frame.maxY {
            let frame = CGRect(x: self.view.frame.origin.x, y: yPosition, width: self.view.bounds.width, height: 30)
            self.bannerView = TFBannerView(withFrame: frame, message: "Tap on Phone icon to enter your phone number. This is to help you to locate friends by asking permission")
            guard  let bannerView = self.bannerView else { return }
            
            self.view.addSubview(bannerView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TFMapLocateMeViewController.dismissBannerView))
            bannerView.addGestureRecognizer(tapGesture)
        }
    }
    
    func dismissBannerView() {
        self.bannerView?.removeFromSuperview()
    }
    
    
    @IBAction func showContactsList(_ sender: Any) {
           let contactViewController = CNContactPickerViewController()
        contactViewController.displayedPropertyKeys = [CNContactUrlAddressesKey, CNContactPostalAddressesKey]
        contactViewController.delegate = self
        self.present(contactViewController, animated: true, completion: nil)

    }
    
    /*
    func findContacts()-> [CNContact] {
        
        var contacts = [CNContact]()
        
        if self.isContactsAccessGranted() {
            DispatchQueue.main.async(execute: { () -> Void in
                do {
                    let predicate: NSPredicate = NSPredicate(value: true)
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactViewController.descriptorForRequiredKeys()] as [Any]
                    contacts = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as! [CNKeyDescriptor])
                    
                }
                catch {
                    print("Unable to refetch the selected contact.")
                }
            })
        }
        
        return contacts
    }
    
    
    func isContactsAccessGranted() -> Bool {
       let authStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        var accessStatus = false
        
        switch authStatus {
        case .authorized:
            accessStatus = true
            return accessStatus
        case .denied, .restricted, .notDetermined:
            accessStatus = false
        }
        
        self.contactStore.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
            if isGranted {
                accessStatus = true
            }
        }
        
        return accessStatus
    } */
}

extension TFMapLocateMeViewController: CNContactPickerDelegate {
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
    }
    
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        
    }
    
    
//    /*!
//     * @abstract Plural delegate methods.
//     * @discussion These delegate methods will be invoked when the user is done selecting multiple contacts or properties.
//     * Implementing one of these methods will configure the picker for multi-selection.
//     */
//    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
//        
//    }
//    
//    public func contactPicker(_ picker: CNContactPickerViewController, didSelectContactProperties contactProperties: [CNContactProperty]) {
//        
//    }
}

extension TFMapLocateMeViewController: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty == false {
            guard let finalLocation = locations.last else { return }
            
             print(finalLocation.horizontalAccuracy)
            
            if finalLocation.horizontalAccuracy < 2000 {
                self.locationManager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: finalLocation.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
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
