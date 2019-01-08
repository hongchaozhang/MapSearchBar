//
//  MSIMWAnnotation.swift
//  MapSearchBar
//
//  Created by Hongchao Zhang on 12/7/16.
//  Copyright © 2016 Hongchao Zhang. All rights reserved.
//

import Foundation

class CustomAnnotation {
    private var name: String

    init(name: String) {
        self.name = name
    }

    func getAnnotationDisplayName() -> String? {
        return self.name
    }
}
