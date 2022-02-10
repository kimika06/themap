//
//  TableViewController.swift
//  OntheMap2
//
//  Created by Mac on 12/1/21.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        UdacityClient.getStudentLocations { studentlocationresults, error in
            if error == nil {
                Student.locations = studentlocationresults
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Data could not load", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addLocation(_ sender: Any) {
        if UdacityClient.User.createdAt == "" {
            performSegue(withIdentifier: "AddStudentFromTable", sender: nil)
        } else {
            showAlert()
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        
        refreshButton.isEnabled = false
        UdacityClient.getStudentLocations { studentlocationresults, error in
            Student.locations = studentlocationresults
            self.tableView.reloadData()
        }
        refreshButton.isEnabled = true
    }
    
    @IBAction func logout(_ sender: Any) {
        UdacityClient.logout { success, error in
            if success{
                self.dismiss(animated: true, completion: nil)
                print("logged out")
            }else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Failed", message: "Cannot log out. Please try again.",  preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Student.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell else {
            fatalError()
        }
        let student = Student.locations[indexPath.row]
            cell.title.text = "\(student.firstName)" + " " + "\(student.lastName)"
            cell.subtitle.text = "\(student.mediaURL)"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = Student.locations[indexPath.row]
        guard let url = URL(string: student.mediaURL) else {return}
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Warning", message: "This location has already been posted. Would you like to overwrite this location?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Overwrite", style: .default) { action in
            if let vc = self.storyboard?.instantiateViewController(identifier: "AddLocationViewContoller") as? AddLocationViewController {
                vc.loadView()
                self.tabBarController?.tabBar.isHidden = true
                vc.linkTextField.text = UdacityClient.User.link
                vc.locationTextField.text = UdacityClient.User.location
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                fatalError("alert error")
            }
        }
        
        let okAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(okAction2)
        present(alert, animated: true, completion: nil)
    }
}
