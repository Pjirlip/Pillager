//
//  TableCell.swift
//  Pillager
//
//  Created by Philipp Dippel on 16.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa

class TableCell: NSTableCellView {

  
    @IBOutlet weak var text: NSTextField!
    
    @IBOutlet weak var image: NSImageView!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
