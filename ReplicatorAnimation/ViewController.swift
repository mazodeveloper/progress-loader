//
//  ViewController.swift
//  ReplicatorAnimation
//
//  Created by joan mazo on 6/14/18.
//  Copyright © 2018 joan mazo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var holderView: HolderView = {
        let view = HolderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        holderView.setupLayers()
        holderView.layer.transform = CATransform3DMakeScale(0, 0, 0)
        holderView.startAnimations()
    }
    
    func setupLayout() {
        view.addSubview(holderView)
        holderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        holderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        holderView.heightAnchor.constraint(equalToConstant: view.frame.width - 80).isActive = true
        holderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
}
