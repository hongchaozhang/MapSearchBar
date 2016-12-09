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
        if self.iconLabel == nil {
            self.iconLabel = UILabel()
            self.addSubview(self.iconLabel!)
        }
        if let theIconLabel = self.iconLabel {
            theIconLabel.text = "icon"
            theIconLabel.sizeToFit()
            let yPosForIcon = (SearchViewUIConstants.TableView.rowHeight - theIconLabel.bounds.size.height) / 2
            theIconLabel.frame = CGRect(x: 0, y: yPosForIcon, width: theIconLabel.bounds.size.width, height: theIconLabel.bounds.size.height)
        }

        if self.contentLabel == nil {
            self.contentLabel = UILabel()
            self.addSubview(self.contentLabel!)
        }

        if let theContentLabel = self.contentLabel {
            theContentLabel.text = contentString
            theContentLabel.sizeToFit()
            let xPosForContent = self.iconLabel!.frame.origin.x + self.iconLabel!.frame.size.width + SearchViewUIConstants.TableView.rightMarginForIcon
            let yPosForContent = (SearchViewUIConstants.TableView.rowHeight - theContentLabel.bounds.size.height) / 2
            let widthForContent = self.bounds.size.width - xPosForContent
            theContentLabel.frame = CGRect(x: xPosForContent, y: yPosForContent, width: widthForContent, height: theContentLabel.bounds.size.height)
        }


    }
}
