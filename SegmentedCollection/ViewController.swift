//
//  ViewController.swift
//  SegmentedCollection
//
//  Created by Trabajo on 24/09/21.
//

import UIKit

class ViewController: UIViewController {
    var segmentedControl:SegmentedCollection!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Ponemos el segmetedControl
        placeSegmetedControl()
        
        
    }
    
    private func placeSegmetedControl(){
        segmentedControl = SegmentedCollection()
        segmentedControl.delegate = self
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(segmentedControl)
        
        segmentedControl.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }


}

extension ViewController:SegmentedControlDelegate{
    func selectedSegment(number: Int) {
        print("selected segment \(number)")
    }
    
    func attemptedToSelectLockedSegment(number: Int) {
        print("tried to select segment \(number)")
    }
    
    
}

