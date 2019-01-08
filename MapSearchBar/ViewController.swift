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
    let layerCount = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addMapView()
        self.addSearchView()
        //        self.addSearchBar()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMapView() {
        self.mapView = MKMapView()
        self.mapView?.frame = self.view.bounds
        self.mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.mapView!)
    }
    
    func addSearchBar() {
        let searchBarViewController = MSIMapSearchBarViewController(maxFrame: CGRect(x: 20, y: 40, width: 300, height: self.view.bounds.size.height), mapView: self.mapView)
        self.addChild(searchBarViewController)
        self.view.addSubview(searchBarViewController.view)
    }
    
    func addSearchView() {
        let searchViewController = MSIMapSearchViewController(maxFrame: CGRect(x: 10, y: 20, width: 300, height: self.view.bounds.size.height - 20 - 20), delegate: self, mapView: self.mapView!)
        self.addChild(searchViewController)
        self.view.addSubview(searchViewController.view)
    }
    
}

extension ViewController: MSIMapSearchViewControllerDelegate {
    
    func getAllAnnotationsInMap() -> [String: [CustomAnnotation]] {
        
        let annotationCountPerLayer = 8
        var allAnnotations = [String: [CustomAnnotation]]()
        
        for layerIndex in 0..<self.layerCount {
            let layerName = "layer \(layerIndex)"
            var annotationArray = [CustomAnnotation]()
            for annotationIndex in 0..<annotationCountPerLayer {
                let annotationName = "annotation \(annotationIndex) of layer \(layerIndex)"
                let annotation = CustomAnnotation(name: annotationName)
                annotationArray.append(annotation)
            }
            
            allAnnotations[layerName] = annotationArray
            
        }
        
        return allAnnotations
    }
    
    func highlightAnnotations(annotations: [String: [CustomAnnotation]]) {
        print("\(annotations)")
    }
    
    func getLayerNames() -> [String] {
        var layerNames = [String]()
        for layerIndex in 0..<self.layerCount {
            layerNames.append("layer \(layerIndex)")
        }
        return layerNames
    }
}
