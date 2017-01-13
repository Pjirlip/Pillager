//
//  CellData.swift
//  Pillager
//
//  Created by Philipp Dippel on 13.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa

class CellData: NSObject {
    
    var name : String = ""
    
    init(name: String) {
        super.init()
        self.name = name
    }
    
}
