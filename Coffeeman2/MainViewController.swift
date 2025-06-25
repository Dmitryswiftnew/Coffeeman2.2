//
//  MainViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 16.06.25.
//

import Foundation
import UIKit
import CoreData

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Coffeeman"
        
        let label = UILabel()
        label.text = "Главный экран Coffeman"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
}
