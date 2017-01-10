//
//  ViewController.swift
//  Youtube Downloader
//
//  Created by Philipp Dippel on 10.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let youtubedlpath : String = "/usr/local/Cellar/youtube-dl/2016.08.06/bin/youtube-dl";
    
    var format : Int?
    
    @IBOutlet weak var urlTextField: NSTextField!
    
    @IBOutlet weak var filename_field: NSTextField!
    
    @IBOutlet var responseText: NSTextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    
    
    @IBAction func browseFile(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                filename_field.stringValue = path
            }
        } else {
            // User clicked on "Cancel"
            return
            
        }
    }
    
    @IBAction func chooseFormat(_ sender: NSButton) {
        
        if(sender.title == "mp4")
        {
            format = 22;
        }
        else
        {
            format = nil;
        }
        
        if (format != nil)
        {
            print(format!)
        }
        
    }
   
  
    
    
    
    
    @IBAction func downloadvideo(_ sender: Any) {
        
        
        let task = Process()
        task.launchPath = youtubedlpath
        if(format != nil){
            task.arguments = ["-f", "140", "-o", filename_field.stringValue + "/%(title)s.%(ext)s" ,urlTextField.stringValue]
        }
        else
        {
            task.arguments = ["-o", filename_field.stringValue + "/%(title)s.%(ext)s" ,urlTextField.stringValue]
        }
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output : String = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        responseText.string = output
    }
    
    @IBAction func checkAvailableFormats(_ sender: Any) {
        let task = Process()
        task.launchPath = youtubedlpath
        task.arguments = ["-F", urlTextField.stringValue]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output : String = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        responseText.string = output
        
    }
    
    

}

