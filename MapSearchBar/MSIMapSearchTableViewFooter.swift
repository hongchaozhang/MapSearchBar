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
    var section: Int
    weak var delegate: MSIMapSearchTableViewFooterDelegate?

    init(frame: CGRect, theSection: Int, theDelegate: MSIMapSearchTableViewFooterDelegate) {
        section = theSection
        delegate = theDelegate
        super.init(frame: frame)
        self.backgroundColor = UIColor.blue
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createButton(text: String) {
        let button = UIButton()
        button.setTitle(text, for: UIControlState.normal)
        button.addTarget(self, action: #selector(MSIMapSearchTableViewFooter.handleButtonClicked), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self.frame.size.width - button.frame.size.width,
                              y: (self.frame.size.height - button.frame.size.height) / 2,
                              width: button.frame.size.width,
                              height: button.frame.size.height)
        self.addSubview(button)
    }

    func handleButtonClicked() {
        self.delegate?.showTypeChange(for: self.section)
    }
}
