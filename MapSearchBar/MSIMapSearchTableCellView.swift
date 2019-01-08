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
    private let showIcon = false
    var iconLabel: UILabel?
    var contentLabel: UILabel?

    func createLabels(searchType: SearchType, contentString: String) {
        self.selectedBackgroundView = UIView()
        
        self.separatorInset = UIEdgeInsets.zero
        if self.iconLabel == nil {
            self.iconLabel = UILabel()
            self.contentView.addSubview(self.iconLabel!)
        }
        if let iconLabel = self.iconLabel, showIcon {
            iconLabel.text = "icon"
            iconLabel.sizeToFit()
            let yPosForIcon = (SearchViewUIConstants.TableView.rowHeight - iconLabel.bounds.size.height) / 2
            iconLabel.frame = CGRect(x: 0, y: yPosForIcon, width: iconLabel.bounds.size.width, height: iconLabel.bounds.size.height)
        }

        if self.contentLabel == nil {
            self.contentLabel = UILabel()
            self.contentLabel?.lineBreakMode = .byTruncatingTail
            self.contentView.addSubview(self.contentLabel!)
        }

        if let contentLabel = self.contentLabel {
            contentLabel.text = contentString
            contentLabel.textColor = SearchViewUIConstants.TableView.cellTextColor
            contentLabel.font = UIFont(name: SearchViewUIConstants.fontFamily, size: SearchViewUIConstants.TableView.cellFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.cellFontSize)
            contentLabel.sizeToFit()
            let xPosForContent = self.iconLabel!.frame.origin.x + self.iconLabel!.frame.size.width + SearchViewUIConstants.TableView.rightMarginForIcon
            let yPosForContent = (SearchViewUIConstants.TableView.rowHeight - contentLabel.bounds.size.height) / 2
            let widthForContent = self.bounds.size.width - xPosForContent
            contentLabel.frame = CGRect(x: xPosForContent, y: yPosForContent, width: widthForContent, height: contentLabel.bounds.size.height)
        }
    }

    func highlightCell() {
        self.contentLabel?.font = UIFont(name: SearchViewUIConstants.highlightFontFamily, size: SearchViewUIConstants.TableView.cellFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.cellFontSize)
    }

    func dehighlightCell() {
        self.contentLabel?.font = UIFont(name: SearchViewUIConstants.fontFamily, size: SearchViewUIConstants.TableView.cellFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.cellFontSize)
    }
}
