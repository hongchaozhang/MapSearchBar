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
        }
    }

    private func customSearchBar() {
//        self.backgroundImage = UIImage()
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor.init(red: 0xC2/255.0, green: 0xC8/255.0, blue: 0xCE/255.0, alpha: 1.0).cgColor
//        self.layer.cornerRadius = 4
//        self.placeholder = "Search"
//        self.setPositionAdjustment(UIOffsetMake(8, 0), for: UISearchBarIcon.search)
//        self.returnKeyType = UIReturnKeyType.done

        self.searchBarStyle = .minimal
        self.placeholder = "Search"
        self.isTranslucent = true
        self.searchTextPositionAdjustment = UIOffsetMake(0, 0)
        self.showsCancelButton = false
        self.setSearchFieldBackgroundImage(MSIMapSearchView.image(with: SearchViewUIConstants.SearchBar.searchFieldBackgroundNormalColor), for: UIControlState.normal)
        self .sizeToFit()

        //            self.searchBar?.searchBarStyle = .prominent
        for subview in self.subviews[0].subviews {
            if let subview = subview as? UITextField {
                subview.layer.borderColor = SearchViewUIConstants.SearchBar.searchFieldBorderColor.cgColor
                subview.layer.borderWidth = SearchViewUIConstants.SearchBar.searchFiledBorderWidth
                subview.layer.cornerRadius = SearchViewUIConstants.SearchBar.searchFieldCornerRadius
                subview.layer.masksToBounds = true

//                let placeholderString = "Search"
//                let attributePlaceholder = NSMutableAttributedString(string: "Search")
//                let range = NSMakeRange(0, placeholderString.characters.count)
//                attributePlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 0xC2, green: 0xC8, blue: 0xCE, alpha: 1.0), range: range)
//                attributePlaceholder.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 18), range: range)
//
//                subview.attributedPlaceholder = attributePlaceholder

//                for textFieldSubview in subview.subviews {
//                    if let textFieldSubview = textFieldSubview as? UILabel {
//                        let font = UIFont(name: ".SFUIText-Regular", size: 14)
//                        textFieldSubview.font = font
//                        textFieldSubview.textColor = UIColor.init(red: 0xC2/255.0, green: 0xC8/255.0, blue: 0xCE/255.0, alpha: 1.0)
//                    }
//                }

//                let font = UIFont(name: ".SFUIText-Regular", size: 20)
//                subview.font = font

//                subview.textColor = UIColor.init(red: 0x00/255.0, green: 0xC8/255.0, blue: 0xCE/255.0, alpha: 1.0)

            }
        }
    }
}
