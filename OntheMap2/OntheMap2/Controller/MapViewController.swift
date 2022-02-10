//
//  MapViewController.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        showPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showPins()
        tabBarController?.tabBar.isHidden = false
    }
    
    func showPins() {
        UdacityClient.getStudentLocations { StudentLocationResults, error in
            
            if error == nil {
                Student.locations = StudentLocationResults
                
                var annotations = [MKPointAnnotation]()
                for student in Student.locations {
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D( latitude:lat, longitude: long)
                    annotation.title = "\(student.firstName)" + " " + "\(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    annotations.append(annotation)
                    self.mapView.addAnnotation(annotation)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Loading error", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .green
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.canOpenURL(URL(string: toOpen)!)
                app.open(URL(string: toOpen)!)
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "", message: "This location has already been posted. Would you like to overwrite this location?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Overwrite", style: .default) { action in
            if let vc = self.storyboard?.instantiateViewController(identifier: "AddLocationViewController") as? AddLocationViewController {
                vc.loadView()
                vc.viewDidLoad()
                vc.linkTextField.text = UdacityClient.User.link
                vc.locationTextField.text = UdacityClient.User.location
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                fatalError("alert error")
            }
        }
        
        let okAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(okAction2)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addLocation(_ sender: Any) {
        if UdacityClient.User.createdAt == "" {
            performSegue(withIdentifier: "AddStudentFromMap", sender: nil)
        } else {
            showAlert()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        showPins()
    }
    
    @IBAction func logout(_ sender: Any) {
        UdacityClient.logout { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print ("logged out")
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Unsuccessful", message: "Could not log out. Please try again", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}
