//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/28/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let udacityClient = UdacityClient.sharedClient()
    private let parseClient = ParseClient.sharedClient()
    private let studentsData = StudentsData.sharedData()
    
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocations()
    }
    
    private func getLocations() {
        parseClient.getStudentLocations() { (locations, error) in
            self.reloadButton.isEnabled = true
            
            guard error == nil else {
                self.showError(error: error!.localizedDescription)
                return
            }
            
            if !locations!.isEmpty {
                self.studentsData.studentLocations = locations!
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateStudents"), object: nil)
            }
        }
    }
    
    private func showError(error: String) {
        let alertView = UIAlertController(title: "Found some error", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Hide", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func didTapAddLocation(_ sender: Any) {
        parseClient.getStudentLocationWithKey(studentsData.currentStudent.student.key!) { (location, error) in
            guard error == nil else {
                self.showError(error: "Couldn´t retrieve key")
                return
            }
            
            if let location = location {
                DispatchQueue.main.async {
                    self.studentsData.currentStudent = StudentWithLocation(objectID: location.objectId, student: location.student, location: location.location!)
                    let postLocationVC = self.storyboard!.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
                    self.present(postLocationVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        udacityClient.logout { (success, error) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didTapReload(_ sender: Any) {
        reloadButton.isEnabled = false
        getLocations()
    }
}
