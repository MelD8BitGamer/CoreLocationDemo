//
//  CoreLocationSession.swift
//  CoreLocationDemo
//
//  Created by Melinda Diaz on 2/21/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import Foundation
import CoreLocation

//WE ARE DEMONSTRATING HERE AND THIS SHOULD BE IN ITS OWN MODEL FILE
struct Location {
    let title: String
    let body: String
    let coordinate: CLLocationCoordinate2D
    let imageName: String
    
    static func getLocations() -> [Location] {
        return [
            Location(title: "Pursuit", body: "We train adults with the most need and potential to get hired in tech, advance in their careers, and become the next generation of leaders in tech.", coordinate: CLLocationCoordinate2D(latitude: 40.74296, longitude: -73.94411), imageName: "team-6-3"),
            Location(title: "Brooklyn Museum", body: "The Brooklyn Museum is an art museum located in the New York City borough of Brooklyn. At 560,000 square feet (52,000 m2), the museum is New York City's third largest in physical size and holds an art collection with roughly 1.5 million works", coordinate: CLLocationCoordinate2D(latitude: 40.6712062, longitude: -73.9658193), imageName: "brooklyn-museum"),
            Location(title: "Central Park", body: "Central Park is an urban park in Manhattan, New York City, located between the Upper West Side and the Upper East Side. It is the fifth-largest park in New York City by area, covering 843 acres (3.41 km2). Central Park is the most visited urban park in the United States, with an estimated 37.5–38 million visitors annually, as well as one of the most filmed locations in the world.", coordinate: CLLocationCoordinate2D(latitude: 40.7828647, longitude: -73.9675438), imageName: "central-park")
        ]
    }
}
//as stated below at the extension you need to initialize it NSObject its superparent
class CoreLocationSession: NSObject {
    
    //    Since we are initializing this CLLocationManager does not need to be banged ///public var locationManager: CLLocationManager! ///
    public var locationManager: CLLocationManager
    
    override init() {
        //COMPILER ERROR:Cannot assign value of type 'CoreLocationSession' to type 'CLLocationManagerDelegate?'
        //SO this is not enough you need an extension/delegate below. i need updates from the delegate on where the user is at so a manager is not enough
        locationManager = CLLocationManager()
        //the super.init() needs to be above the delegate BUT NOT CLLocationManager() !!!
        super.init()
        locationManager.delegate = self
        
        //request the user location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
//        The following keys need to be added to the info p.list file from your console(or at least that is what your console ask of you) look at line 25 of notes
// We need to give them description
//        * NSLocationWhenInUseUsageDescription
//        * NSLocationAlwaysAndWhenInUseUsageDescription
     
        //get updates for userLocation, this is the more aggressive solution for GPS data collection
        /// locationManager.startUpdatingLocation()
        
        //less aggressive on battery and GPS data collection
        startSignificantChanges()
        startMonitoringRegion()
    }
    
    private func startSignificantChanges() {
        //if it is not available !
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            return
        }
        //less aggressive than the startUpdatingLocation() in GPS monitoring changes
        locationManager.startMonitoringSignificantLocationChanges()
    }
    //we can call this in our VC
    public func convertCoordinateToPlacemark(coordinate: CLLocationCoordinate2D) {
        //we will use the CLGeocoder() class for converting coordinate (CLLocationCoordinate2D) to placemark (CLPlacemark) we can grab anything we want and ther eis alot of information about the place
        //CLGeocoder() calls apple's location API
        //we need to creat a CLLocatiohn
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            //there are better location maps with more information and data. Like GoogleMaps and other 3RD party like mapbox etc
            if let error = error {
                print("reverseGeocodingLocation \(error)")
            }
            if let firstPlacemark = placemarks?.first {
                print("placemark info \(firstPlacemark)")
            }
        }
    }
    public func convertPlaceNameToCoordinate(addressString: String) {
        //converting an address to coordinate
        CLGeocoder().geocodeAddressString("") { (placemarks, error) in
            if let error = error {
                print("goecodeAddressString: \(error)")
            }
            if let firstPlaceName = placemarks?.first,
                let location = firstPlaceName.location {
                print("coordinate\(location.coordinate)")
            }
        }
    }
    //TIME:12:17PM monitor a CLRegion- it is made up of a center coordinate and a radius in meters we call this in our override init()
    private func startMonitoringRegion() {
        let location = Location.getLocations()[2]//central park
        //we need a coordinate and identifier
        let identifier = "monitoring region"
        let region = CLCircularRegion(center: location.coordinate, radius: 500, identifier: identifier)
        //it will update the region when it enters or leaves the radius, the default is value is usually true
        region.notifyOnEntry = true
        region.notifyOnExit = false
        //our location manager now listens to the changes and now the function in the extension didEnterRegion, if you do not call this you will get an error
        locationManager.startMonitoring(for: region)
    }
}

extension CoreLocationSession: CLLocationManagerDelegate {
    //MARK: Core Location is very tied to OBJ C. NSObject is the superparent of the classes . Core Location needs to conform to NSObject protocol. Core Location session is the OBJECT that says i want to set myself as delegate manager so it needs to conform from NSObject.At that point we are overriding the init() cause now it sees that CoreLocation as a subClass of NSObject. A SUBCLASS NEEDS TO OVERRIDE THE INITIALIZER. So we mark it with an override because we inherit from NSObject.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //its gives back an array because there are multiple locations it receives. You want the last of that array. So it will be //locations.last That method gets called when the user changes location.
        print("didUpdatelocations \(locations)")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //what is the current access to the user services, do you have access or not?
        switch status {
        case .authorizedAlways:
            print("authorizedAlways - always has access")
        case .authorizedWhenInUse:
            print("authorizationWhen In use - only has info when the app is in use")
        case .denied:
            // document says The user denied the use of location services for the app or they are disabled globally in Settings.
            print("denied - user denied access")
        case .notDetermined:
            print("not determined - has not prompted the user yet")
        case .restricted:
            print("restricted - The app is not access there is not enough info on it")
            //document says The app is not authorized to use location services look at https://developer.apple.com/documentation/corelocation/clauthorizationstatus
        //we need a default case cause apple might make more cases
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //we use that to see if we entered regions like a circle it has a center and a radius
        print("Did enter Region \(region)")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Did Exit Region \(region)")
    }
}
