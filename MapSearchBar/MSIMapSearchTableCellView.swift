//
//  MSIMapSearchTableCellView.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/9/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation
import UIKit

public class MSIMapSearchTableCellView: UITableViewCell {
    var iconLabel: UILabel?
    var contentLabel: UILabel?

    func createLabels(searchType: SearchType, contentString: String) {
        self.selectedBackgroundView = UIView()
        
        self.separatorInset = UIEdgeInsets.zero
        if self.iconLabel == nil {
            self.iconLabel = UILabel()
            self.contentView.addSubview(self.iconLabel!)
        }
        if let theIconLabel = self.iconLabel {
            theIconLabel.text = "icon"
            theIconLabel.sizeToFit()
            let yPosForIcon = (SearchViewUIConstants.TableView.rowHeight - theIconLabel.bounds.size.height) / 2
            theIconLabel.frame = CGRect(x: 0, y: yPosForIcon, width: theIconLabel.bounds.size.width, height: theIconLabel.bounds.size.height)
        }

        if self.contentLabel == nil {
            self.contentLabel = UILabel()
            self.contentView.addSubview(self.contentLabel!)
        }

        if let theContentLabel = self.contentLabel {
            theContentLabel.text = contentString
            theContentLabel.textColor = SearchViewUIConstants.TableView.cellTextColor
            theContentLabel.font = UIFont(name: SearchViewUIConstants.fontFamily, size: SearchViewUIConstants.TableView.cellFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.cellFontSize)
            theContentLabel.sizeToFit()
            let xPosForContent = self.iconLabel!.frame.origin.x + self.iconLabel!.frame.size.width + SearchViewUIConstants.TableView.rightMarginForIcon
            let yPosForContent = (SearchViewUIConstants.TableView.rowHeight - theContentLabel.bounds.size.height) / 2
            let widthForContent = self.bounds.size.width - xPosForContent
            theContentLabel.frame = CGRect(x: xPosForContent, y: yPosForContent, width: widthForContent, height: theContentLabel.bounds.size.height)
        }

    }

    func highlightCell() {
        self.contentLabel?.font = UIFont(name: SearchViewUIConstants.highlightFontFamily, size: SearchViewUIConstants.TableView.cellFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.cellFontSize)
//        self.backgroundColor = UIColor.white
    }

    func dehighlightCell() {
        self.contentLabel?.font = UIFont(name: SearchViewUIConstants.fontFamily, size: SearchViewUIConstants.TableView.cellFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.cellFontSize)
//        self.backgroundColor = UIColor.white
    }
}
