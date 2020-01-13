//
//  ViewController.swift
//  Next Adventure
//
//  Created by Mike Dix on 1/6/20.
//  Copyright © 2020 Mike Dix. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager() //object that you use to start and stop the delivery of location-related events to your app
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var chosenLatitude = Double()
    var chosenLongitiude = Double()
    
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLongitude = Double()
    var annotiationLatitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view did load delegates
        mapView.delegate = self
        locationManager.delegate = self
        
        //accuracy of location on map to best so the user can see exact places
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //get permission of user for location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 1.75
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != "" {
            //core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                        if let subtitle = result.value(forKey: "subtitle") as? String {
                            annotationSubTitle = subtitle
                            
                        if let latitude = result.value(forKey: "latitude") as? Double {
                            annotiationLatitude = latitude
                           
                        if let longitude = result.value(forKey: "longitude") as? Double {
                            annotationLongitude = longitude
                            
                            let annotation = MKPointAnnotation()//point on map
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubTitle
                            let coordinate = CLLocationCoordinate2D(latitude: annotiationLatitude, longitude: annotationLongitude)
                            annotation.coordinate = coordinate
                            
                            //show pin
                            mapView.addAnnotation(annotation)
                            nameText.text = annotationTitle
                            commentText.text = annotationSubTitle
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }

            
        } else {
            //add new data
        }
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
            //gives us wherever user touched on the view
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            
            //gives us the coordinates of the touched point of the user on the view
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitiude = touchedCoordinates.longitude
            
            //annotation showed on the touched point on map
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation) 
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //gives current location of user
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        //how much i want to zoom in the map
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        //where i center this location on the mao
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        //core data setup
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        
        newLocation.setValue(nameText.text, forKey: "title")
        newLocation.setValue(commentText.text, forKey: "subtitle")
        newLocation.setValue(chosenLatitude, forKey: "latitude")
        newLocation.setValue(chosenLongitiude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
    }

}

