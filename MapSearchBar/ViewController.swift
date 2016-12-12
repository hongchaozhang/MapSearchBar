//
//  ViewController.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/5/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addMapView()
        
//        self.addSearchBar()
        self.addSearchView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMapView() {
        self.mapView = MKMapView()
        self.mapView?.frame = self.view.bounds
        self.view.addSubview(self.mapView!)
    }
    
    func addSearchBar() {
        let searchBarViewController = MSIMapSearchBarViewController(theMaxFrame: CGRect(x: 20, y: 40, width: 300, height: self.view.bounds.size.height), theMapView: self.mapView)
        self.addChildViewController(searchBarViewController)
        
        self.view.addSubview(searchBarViewController.view)
    }

    func addSearchView() {
        let searchViewController = MSIMapSearchViewController(theMaxFrame: CGRect(x: 10, y: 40, width: 300, height: self.view.bounds.size.height - 40 - 20), theDelegate: nil, theMapView: self.mapView!)
        searchViewController.delegate = self
        self.addChildViewController(searchViewController)

        self.view.addSubview(searchViewController.view)
    }

}

extension ViewController: MSIMapSearchViewControllerDelegate {

    func getAllAnnotationsInMap() -> [String: [MSIMWAnnotation]] {

        let layerCount = 4
        let annotationCountPerLayer = 8
        var allAnnotations = [String: [MSIMWAnnotation]]()

        for layerIndex in 0..<layerCount {
            let layerName = "layer \(layerIndex)"
            var annotationArray = [MSIMWAnnotation]()
            for annotationIndex in 0..<annotationCountPerLayer {
                let annotationName = "annotation \(annotationIndex) of layer \(layerIndex)"
                let annotation = MSIMWAnnotation(name: annotationName)
                annotationArray.append(annotation)
            }

            allAnnotations[layerName] = annotationArray

        }

        return allAnnotations
    }

    func highlightAnnotations(annotations: [String: [MSIMWAnnotation]]) {
        print("\(annotations)")
    }

    func getLayerNames() -> [String] {
        let layerCount = 4
        var layerNames = [String]()
        for layerIndex in 0..<layerCount {
            layerNames.append("layer \(layerIndex)")
        }
        return layerNames
    }
}
