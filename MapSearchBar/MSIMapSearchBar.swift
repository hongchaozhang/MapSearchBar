//
//  MSIMapSearchBar.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/12/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation
import UIKit

public class MSIMapSearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customSearchBar()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        for subview in self.subviews[0].subviews {
            if let subview = subview as? UITextField {
                var frame = subview.frame
                let yOffset = (SearchViewUIConstants.SearchBar.height - frame.size.height) / 2.0
                frame.size.height = SearchViewUIConstants.SearchBar.height
                frame.origin.y -= yOffset

                subview.frame = frame
            }

            if let subview = subview as? UIButton {
                subview.tintColor = SearchViewUIConstants.searchBarCancelButtonTintColor
                if let titleLabel = subview.titleLabel {
                    titleLabel.font = UIFont(name: ".SFUIText-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
                }
                var cancelButtonFrame = subview.frame
                let superViewFrame = subview.superview?.frame
                if let superViewFrame = superViewFrame {
                    cancelButtonFrame.origin.x = superViewFrame.size.width - cancelButtonFrame.size.width
                    cancelButtonFrame.origin.y = (superViewFrame.size.height - cancelButtonFrame.size.height) / 2.0
                    subview.frame = cancelButtonFrame
                }
            }
        }
    }

    private func customSearchBar() {
        self.searchBarStyle = .minimal
        self.placeholder = "Search"
        self.isTranslucent = true
        self.searchTextPositionAdjustment = UIOffset.init(horizontal: 8, vertical: 0)
        self.showsCancelButton = false
        self.setSearchFieldBackgroundImage(MSIMapSearchView.image(with: SearchViewUIConstants.SearchBar.searchFieldBackgroundNormalColor), for: UIControl.State.normal)
        self .sizeToFit()

        for subview in self.subviews[0].subviews {
            if let subview = subview as? UITextField {
                subview.layer.borderColor = SearchViewUIConstants.SearchBar.searchFieldBorderColor.cgColor
                subview.layer.borderWidth = SearchViewUIConstants.SearchBar.searchFiledBorderWidth
                subview.layer.cornerRadius = SearchViewUIConstants.SearchBar.searchFieldCornerRadius
                subview.layer.masksToBounds = true
            }
        }
    }
}
