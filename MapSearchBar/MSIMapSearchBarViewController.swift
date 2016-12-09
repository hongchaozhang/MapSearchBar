//
//  MapSearchBarViewController.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/5/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol MSIMapSearchBarViewDelegate: class {
    
}

class MSIMapSearchBarViewController: UIViewController, MSIMapSearchBarViewDelegate {
    
    var maxViewFrame: CGRect
    weak var mapView: MKMapView?
    var localSearch: MKLocalSearch?
    
    init(theMaxFrame: CGRect, theMapView: MKMapView?) {
        maxViewFrame = theMaxFrame
        mapView = theMapView
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        if self.localSearch != nil {
            self.localSearch!.cancel()
            self.localSearch = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(theMaxFrame: CGRect(x: 0, y: 0, width: 100, height: 100), theMapView: nil)
    }
    
    override func loadView() {
        let searchView = MSIMapSearchBarView(frame: self.maxViewFrame)
        searchView.viewDelegate = self
        searchView.generateView()
        searchView.searchBar?.delegate = self
        self.view = searchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MSIMapSearchBarViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSLog(searchText)
        
        guard let mapView = self.mapView else {
            return
        }
        
        if self.localSearch != nil {
            self.localSearch!.cancel()
            self.localSearch = nil
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        
        self.localSearch = MKLocalSearch(request: request)
        self.localSearch?.start(completionHandler: {(response, error) in
            guard let response = response else {
                print("Search error: \(error)")
                return
            }
            
            for item in response.mapItems {
                print("\(item)")
            }
        })
        
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel button is clicked")
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button is clicked")
    }

    // swiftlint:disable line_length
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    // swiftlint:enable line_length
//        print("scope button is clicked: \(selectedScope)")
    }
    
    public func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("results list button is clicked")
    }
}
