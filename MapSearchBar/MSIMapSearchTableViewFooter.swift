//
//  MSIMapSearchViewTableViewFooter.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/9/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation
import UIKit

public protocol MSIMapSearchTableViewFooterDelegate: class {
    func showTypeChange(for section: Int)
}

public class MSIMapSearchTableViewFooter: UIView {
    var section: Int!
    weak var delegate: MSIMapSearchTableViewFooterDelegate?
    
    init(frame: CGRect, section: Int, delegate: MSIMapSearchTableViewFooterDelegate) {
        super.init(frame: frame)
        self.section = section
        self.delegate = delegate
        self.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createButton(text: String) {
        let button = UIButton()
        
        let attributedTitle = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.count)
        attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: SearchViewUIConstants.TableView.footerButtonTintColor, range: range)
        attributedTitle.addAttribute(NSAttributedString.Key.font, value: UIFont(name: ".SFUIText-Regular", size: SearchViewUIConstants.TableView.footerFontSize) ?? UIFont.systemFont(ofSize: SearchViewUIConstants.TableView.footerFontSize), range: range)
        
        button.setAttributedTitle(attributedTitle, for: UIControl.State.normal)
        
        button.addTarget(self, action: #selector(MSIMapSearchTableViewFooter.handleButtonClicked), for: UIControl.Event.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self.frame.size.width - button.frame.size.width,
                              y: (self.frame.size.height - button.frame.size.height) / 2,
                              width: button.frame.size.width,
                              height: button.frame.size.height)
        self.addSubview(button)
        
        let separatorHeight: CGFloat = SearchViewUIConstants.TableView.sectionSeparatorHeight
        let separator = UIView(frame: CGRect(x: 0, y: self.frame.size.height - separatorHeight, width: self.frame.size.width, height: separatorHeight))
        separator.backgroundColor = UIColor(red: 0xC2/255.0, green: 0xC8/255.0, blue: 0xCE/255.0, alpha: 1.0)
        self.addSubview(separator)
    }
    
    @objc func handleButtonClicked() {
        self.delegate?.showTypeChange(for: self.section)
    }
}
