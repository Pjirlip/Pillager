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
    
    var format : String?
    
    @IBOutlet weak var urlTextField: NSTextField!
    
    @IBOutlet weak var filename_field: NSTextField!
    
    @IBOutlet var responseText: NSTextView!
    
    @IBOutlet weak var downloadButton: NSButton!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var progressPie: NSProgressIndicator!
    
    @IBOutlet weak var refresh: NSButton!
    
    
    //Radio Buttons Codec Types
    
    @IBOutlet weak var mp4Radio: NSButton!
    @IBOutlet weak var webmRadio: NSButton!
    @IBOutlet weak var flvRadio: NSButton!
    @IBOutlet weak var mp3Radio: NSButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textchanged), name: NSNotification.Name.NSControlTextDidChange, object: urlTextField)
        
        mp4Radio.isEnabled = false
        mp3Radio.isEnabled = false
        flvRadio.isEnabled = false
        webmRadio.isEnabled = false
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    func textchanged(notif : NSNotification)
    {
        print("HALLO")
        checkAvailableFormats(refresh)
    }
    

    
    
    @IBAction func browseFile(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a Path for Download";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles          = false;
        
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
            format = "mp4";
        }
        else if(sender.title == "webm")
        {
            format = "webm"
        }
        else if(sender.title == "flv")
        {
            format = "flv"
        }
        else if(sender.title == "mp3 (Audio only) ")
        {
            format = "mp3"
        }
        else
        {
            format = nil;
        }
       
        
    }
    
    
    
    
    
    
    @IBAction func downloadvideo(_ sender: Any) {
        
        self.responseText.string! = "";
        self.progressPie.minValue = 0.0
        self.progressPie.maxValue = 100.0
        self.progressPie.doubleValue = 0.0
        
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            self.progressIndicator.startAnimation(self)
            
            let task = Process()
            task.launchPath = self.youtubedlpath
            if(self.format != nil){
                task.arguments = ["-f", "137+140", "-o", self.filename_field.stringValue + "/%(title)s.%(ext)s" ,self.urlTextField.stringValue]
            }
            else
            {
                task.arguments = ["-o", self.filename_field.stringValue + "/%(title)s.%(ext)s" ,self.urlTextField.stringValue]
            }
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            let outHandle = pipe.fileHandleForReading
            
            outHandle.readabilityHandler =
                { pipe in
                    if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8)
                    {
                        // Update your view with the new text here
                        //print("New ouput: \(line)")
                        
                        
                        DispatchQueue.main.async
                            {
                                self.responseText.string = self.responseText.string! + line
                                
                                
                                let indexofpercent = line.characters.index(of: "%")
                                if(indexofpercent != nil) {
                                    
                                    let endofindex = indexofpercent!
                                    
                                    if(line.distance(from: line.startIndex, to: indexofpercent!) == 17)
                                    {
                                        let startofindex = line.index(indexofpercent!, offsetBy: -5)
                                        let range = Range(uncheckedBounds: (lower: startofindex, upper: endofindex))
                                        
                                        let substring = line[range]
                                        let trimmedString = substring.trimmingCharacters(in: .whitespaces)
                                        
                                        let myDouble = Double(trimmedString)
                                        
                                        if(myDouble != nil)
                                        {
                                            
                                            self.progressPie.doubleValue = myDouble!
                                        }
                                    }
                                }
                                
                                
                                
                                
                        }
                    }
                    else {
                        print("Error decoding data: \(pipe.availableData)")
                    }
            }
            task.launch()
            task.waitUntilExit()
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                
                self.progressIndicator.stopAnimation(self)
                
                
            }
        }
        
        
    }
    
    @IBAction func checkAvailableFormats(_ sender: Any) {
        
        
        mp4Radio.isEnabled = false;
        webmRadio.isEnabled = false;
        flvRadio.isEnabled = false;
        mp3Radio.isEnabled = false;
        
        
        self.responseText.string = ""
        let task = Process()
        task.launchPath = youtubedlpath
        task.arguments = ["-F", urlTextField.stringValue]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        self.progressIndicator.startAnimation(self)
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler =
            { pipe in
                if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8)
                {
                    // Update your view with the new text here
                    //print("New ouput: \(line)")
                    
                    
                    let regexpattern = "\\R[0-9]{2,3}\\s"
                    
                    var codecs = self.matches(for: regexpattern, in: line)
                    
                    var avaliablecodecs = [Double]()
                    
                    if(codecs.isEmpty != true)
                    {
                        for (index, _) in codecs.enumerated() {
                            codecs[index] = (codecs[index] as NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                            
                            let codec = codecs[index]
                            let insert = Double(codec)
                            
                            avaliablecodecs.append(insert!)
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        
                        //Check for MP4
                        if(avaliablecodecs.contains(22))
                        {
                            self.mp4Radio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(134))
                        {
                            self.mp4Radio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(135))
                        {
                            self.mp4Radio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(136))
                        {
                            self.mp4Radio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(137))
                        {
                            self.mp4Radio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(138))
                        {
                            self.mp4Radio.isEnabled = true;
                        }
                        
                        
                        //Check for WEBM
                        if(avaliablecodecs.contains(247))
                        {
                            self.webmRadio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(243))
                        {
                            self.webmRadio.isEnabled = true;
                        }
                        if(avaliablecodecs.contains(313))
                        {
                            self.webmRadio.isEnabled = true;
                        }
                        
                        //Check for FLV
                        if(avaliablecodecs.contains(5))
                        {
                            self.flvRadio.isEnabled = true;
                        }
                        
                        //Check Audio
                        if(avaliablecodecs.contains(140))
                        {
                            self.mp3Radio.isEnabled = true;
                        }

                        
                        
                        
                        
                    }
                    
                    
                    
                    DispatchQueue.main.async
                        {
                            self.responseText.string = self.responseText.string! + line
                            self.progressIndicator.stopAnimation(self)
                            
                    }
                    
                    
                    
                }
                else {
                    print("Error decoding data: \(pipe.availableData)")
                    
                }
        }
        task.launch()
        task.waitUntilExit()
        
        
        
    }
    
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    
}

