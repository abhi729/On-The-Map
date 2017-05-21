//
//  StudentTableController.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 19/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit

class StudentTableController: UIViewController {
    
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        
        if studentTableView.numberOfRows(inSection: 0) != 0 {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        super.viewDidAppear(animated)
    }
    
    func studentLocationUpdated() {
        
        if activityIndicator != nil {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        if studentTableView != nil {
            studentTableView.reloadData()
        }
    }
    
    
}

extension StudentTableController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let student = Students.infoArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentTableCell
        cell.nameLabel.text = "\(student.firstName ?? "") \(student.lastName ?? "")"
        return cell
        
    }
    
}

extension StudentTableController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = Students.infoArray[indexPath.row]
        if let url = URL(string: student.mediaUrlString ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
}
