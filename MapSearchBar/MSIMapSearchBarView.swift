//
//  MSIMapSearchBarView.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/5/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation
import UIKit

class MSIMapSearchBarView: UIView {
    
    var label: UILabel?
    var searchBar: UISearchBar?
    
    weak var viewDelegate: MSIMapSearchBarViewDelegate?
    
    open func generateView() {
//        self.label = UILabel(frame: CGRect(x: 0, y: 100, width: 100, height: 200))
//        self.label?.text = "test"
//        self.label?.backgroundColor = UIColor.red
//        self.addSubview(self.label!)
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 40))
        self.searchBar!.searchBarStyle = UISearchBarStyle.default
        self.searchBar!.placeholder = "Search"
//        self.searchBar!.tintColor = UIColor.blue
        self.searchBar!.isTranslucent = true
        self.searchBar!.searchTextPositionAdjustment = UIOffsetMake(0, 0)
        self.searchBar!.showsScopeBar = true
        self.searchBar!.scopeButtonTitles = ["Dataset", "Map"]
        self.searchBar!.selectedScopeButtonIndex = 0
//        self.searchBar!.showsBookmarkButton = true
        self.searchBar!.showsCancelButton = true
        
        self.addSubview(self.searchBar!)
    }
}
