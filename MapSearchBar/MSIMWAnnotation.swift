//
//  MSIMWAnnotation.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/7/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation

class MSIMWAnnotation {
    var name: String

    init(name: String) {
        self.name = name
    }

    func getFirstAttributeDisplayFormValue() -> String? {
        return self.name
    }
}
