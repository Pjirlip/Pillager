//
//  TableCell.swift
//  Pillager
//
//  Created by Philipp Dippel on 16.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa

class TableCell: NSTableCellView {

  
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBOutlet weak var text: NSTextField!
    
    @IBOutlet weak var image: NSImageView!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var task : Process? = nil
    
    var index : Int? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func cancleTask(_ sender: Any) {
        
        if(task != nil)
        {
        
    
        
            while(task?.isRunning)!
            {
                task?.terminate()
                task?.interrupt()
            }
            
            
        progressBar.doubleValue = 100
        text.stringValue = "Task Interrupted!"

        
        NotificationCenter.default.post(name: NSNotification.Name.init("TimeToUpdate"), object: self)
        
            
        }
        
        
        
    }
    
    
    
    
}
