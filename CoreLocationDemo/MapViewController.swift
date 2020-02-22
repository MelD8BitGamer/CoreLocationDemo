//
//  ViewController.swift
//  CoreLocationDemo
//
//  Created by Melinda Diaz on 2/21/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import UIKit
import MapKit
//YOU MUST IMPORT MAPKIT IN ORDER TO USE MAPS
class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    private let locationSession = CoreLocationSession()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //testing converting coordinate placemark
        convertCoordinateToPlacemark()
        convertPlaceNameToCoordinate()
        //configure mapview to show the user location now if the services are off we will not see the your location on the map
        mapView.showsUserLocation = true
        //we also need to write an extension
        mapView.delegate = self
        loadMapView()
    }
    func makeAnnotations() -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        //we will go throught he array of annotations and make annotation and the minumumm needs a coordinate
        for location in Location.getLocations(){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = location.title
            annotations.append(annotation)
        }
        return annotations
    }
    //call this oin the viewDidLoad but we have more work so we need a delegate we will use a pin annotation . So we have a delegate in the viewDIdLoad
    private func loadMapView() {
        let annotations = makeAnnotations()
        mapView.addAnnotations(annotations)
        //This will zoom in and show as many annotations as you can on the maoview. So it is a more zoomed result
        mapView.showAnnotations(annotations, animated: true)
    }

    private func convertCoordinateToPlacemark() {
        //usually we use a completionhandler when we do this
        if let location = Location.getLocations().first {
            locationSession.convertCoordinateToPlacemark(coordinate: location.coordinate)
        }
    }
    private func convertPlaceNameToCoordinate() {
        locationSession.convertPlaceNameToCoordinate(addressString: "Queens Center Mall")
    }
}
//when i click on an annotation a method gets called in the extension
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
    }
    //another method that can get called //this is like a cell for row at but for mapkit //MARK: 12:47
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKPointAnnotation else {
        return nil
    }
    //if it does exsist we will use it if not we will make a new one and the identifier  string only matters when you delete it
    let identifier = "locationAnnotation"
    var annotationView: MKPinAnnotationView
    ///try to deque and reuse annotation view
    if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
        annotationView = dequeueView
    } else {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.canShowCallout = true
    }
    return annotationView
  }
    //this makes the annotations(pins) bubble up when hovering over with your cursor
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
    }
   
    
}


