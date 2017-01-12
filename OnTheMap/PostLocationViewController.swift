//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/29/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, MKMapViewDelegate {
    
    private let parseClient = ParseClient.sharedClient()
    private let studentsData = StudentsData.sharedData()
    private var pin: CLPlacemark?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isHidden = true
        
        locationTextField.clearsOnBeginEditing = true
        topTextField.clearsOnBeginEditing = true
        
        topTextField.delegate = self
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.stopAnimating()
    }
    
    private func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapFindOnTheMap(_ sender: Any) {
        if locationTextField.text!.isEmpty {
            showAlert("Without location we can continue")
            return
        }
        activityIndicator.startAnimating()
        DispatchQueue.main.async {
            let geocoder = CLGeocoder()
            do {
                geocoder.geocodeAddressString(self.locationTextField.text!, completionHandler: { (results, error) in
                    if let _ = error {
                        self.showAlert("Imposible to geolocate")
                        self.activityIndicator.stopAnimating()
                        return
                    } else if results!.isEmpty {
                        self.showAlert("No results for that location")
                        self.activityIndicator.stopAnimating()
                        return
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.topTextField.text = "Enter a link to share"
                        self.topTextField.isEnabled = true
                        
                        self.middleView.isHidden = true
                        self.locationTextField.isHidden = true
                        
                        self.bottomView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                        self.findOnMapButton.isHidden = true
                        self.submitButton.isHidden = false
                        
                        self.pin = results![0]
                        self.mapView.showAnnotations([MKPlacemark(placemark: self.pin!)], animated: true)
                    }
                })
            }
        }
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        if topTextField.text!.isEmpty {
            showAlert("Please enter a url!!")
            return
        }
        
        activityIndicator.startAnimating()
        
        studentsData.currentStudent.location = Location(lat: pin!.location!.coordinate.latitude, long: pin!.location!.coordinate.longitude, map: locationTextField.text!)
        studentsData.currentStudent.student.url = topTextField.text!
        
        if let _ = studentsData.currentStudent.objectId {
            parseClient.updateStudentLocationWithObjectID(studentwithLocation: studentsData.currentStudent, completionHandler: { (success, error) in
                
                guard error == nil else {
                    self.showAlert(error!.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                if success {
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateStudents"), object: nil)
                }
            })
        } else {
            parseClient.postStudentLocation(studentsData.currentStudent) { (success, error) in
                
                guard error == nil else {
                    self.showAlert(error!.localizedDescription)
                    return
                }
                
                if success {
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateStudents"), object: nil)
                }
            }
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PostLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
