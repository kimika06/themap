//
//  FinishLocationViewController.swift
//  OntheMap2
//
//  Created by Mac on 11/7/21.
//

import UIKit
import MapKit

class FinishLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishButton: UIButton!
    
    var link: String = ""
    var latitude: Double = 33.75
    var longitude: Double = 84.39
    var location: String = ""
    var firstName: String = ""
    var lastName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMapAnnotation()
        tabBarController?.tabBar.isHidden = true
        activityIndicator.isHidden = true
        
    }
    
    
    @IBAction func finishTapped(_ sender: Any) {
        setActivityIndicator(true)
        if UdacityClient.User.createdAt == "" {
            UdacityClient.getUser(completion: getUserData(firstName:lastName:error:))
        }else {
            UdacityClient.updateLocation(firstName: UdacityClient.User.firstName, lastName: UdacityClient.User.lastName, mapString: location, mediaURL: link, latitude: latitude, longitude: longitude, completion: updatedLocation(success:error:))
        }
    }
    
    func getUserData(firstName: String?, lastName: String?, error: Error?) {
        if error == nil {
            UdacityClient.postLocation(firstName: firstName ?? "", lastName: lastName ?? "", mapString: location, mediaURL: link, latitude: latitude, longitude: longitude, completion: postedLocation(success:error:))
        }else{
            print("User data is not handled.")
        }
    }
    
    func postedLocation(success: Bool, error: Error?) {
        setActivityIndicator(false)
        if success {
            UdacityClient.User.location = location
            print(UdacityClient.User.location)
            UdacityClient.User.link = link
            print(" student added")
            navigationController?.popToRootViewController(animated: true)
        }else{
            let alert = UIAlertController(title: "Error", message: "Student cannot be added. Please try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            print("Student cannot be added.")
        }
    }
    
    func updatedLocation(success: Bool, error: Error?) {
        if success{
            UdacityClient.User.location = location
            UdacityClient.User.link = link
            print("Student updated")
            navigationController?.popToRootViewController(animated: true)
        }else{
            print("Student cannot be updated.")
        }
    }
    
    func createMapAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = self.latitude
        annotation.coordinate.longitude = self.longitude
        annotation.title = location
        self.mapView.addAnnotation(annotation)
        
        self.mapView.setCenter(annotation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func setActivityIndicator(_ running : Bool) {
        if running {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }else{
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
        finishButton.isEnabled = !running
        activityIndicator.isHidden = !running
    }
}
