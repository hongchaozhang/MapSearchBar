//
//  MSIMapSearchTableViewHeader.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/12/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation
import UIKit

public class MSIMapSearchTableViewHeader: UIView {
    init(frame: CGRect, theText: String?) {
        super.init(frame: frame)
        self.createSpaceView()
        self.createContentView(theText: theText)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSpaceView() {
        let space = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: SearchViewUIConstants.TableView.sectionSpace))
        space.backgroundColor = UIColor.white
        self.addSubview(space)
    }

    private func createContentView(theText: String?) {
        let label = UILabel(frame: CGRect(x: 0, y: SearchViewUIConstants.TableView.sectionSpace, width: self.frame.size.width, height: self.frame.size.height - SearchViewUIConstants.TableView.sectionSpace))
        label.text = theText
        label.textColor = SearchViewUIConstants.TableView.headerLabelColor
        label.font = UIFont(name: ".SFUIText-Regular", size: SearchViewUIConstants.TableView.headerFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.headerFontSize)
        label.textAlignment = .left
        label.backgroundColor = UIColor.white

        self.addSubview(label)
    }
}
