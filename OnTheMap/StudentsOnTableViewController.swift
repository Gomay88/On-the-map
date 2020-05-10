//
//  StudentsOnTableViewController.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/29/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import UIKit

class StudentsOnTableViewController: UITableViewController {
    
    let studentsData = StudentsData.sharedData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: Notification.Name(rawValue: "updateStudents"), object: nil)
    }
    
    @objc func updateTable() {
        tableView.reloadData()
    }
    
    private func showError(error: String) {
        let alertView = UIAlertController(title: "Found some error", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Hide", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let url = studentsData.studentLocations?[indexPath.row].student.url
        
        if let url = URL(string: url!) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                showError(error: "The url is invalid")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsData.studentLocations!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentsOnTableViewCell") as! StudentsOnTableViewCell
        let studentLocation = studentsData.studentLocations?[indexPath.item]
        cell.configureWithStudentLocation(studentLocation!)
        return cell
    }
}
