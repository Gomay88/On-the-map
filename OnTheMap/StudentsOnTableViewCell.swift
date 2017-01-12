//
//  StudentsOnTableViewCell.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/29/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import UIKit

class StudentsOnTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    func configureWithStudentLocation(_ studentWithLocation: StudentWithLocation) {
        pinImageView.image = UIImage(named: "Pin")
        nameLabel.text = studentWithLocation.student.firstName + " " + studentWithLocation.student.lastName
        urlLabel.text = studentWithLocation.student.url
    }
}
