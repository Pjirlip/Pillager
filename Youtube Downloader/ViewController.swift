//
//  ViewController.swift
//  Youtube Downloader
//
//  Created by Philipp Dippel on 10.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    
    let youtubedlpath : String = "/usr/local/Cellar/youtube-dl/2016.08.06/bin/youtube-dl"
    let ffmpegpath : String = "/usr/local/Cellar/ffmpeg/3.1.1_1/bin/ffmpeg"
    
    var format : String?
    
    @IBOutlet weak var urlTextField: NSTextField!
    
   
    
    @IBOutlet var responseText: NSTextView!
    
    @IBOutlet weak var downloadButton: NSButton!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var progressPie: NSProgressIndicator!
    
    @IBOutlet weak var refresh: NSButton!
    
    @IBOutlet weak var choosePath: NSPathControl!
    
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var splitLowerView: NSView!
    
    
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
        
        var fileUrl = Foundation.URL(string: NSHomeDirectory())
        fileUrl?.appendPathComponent("Downloads", isDirectory: true)
        choosePath.url = fileUrl
        
        splitLowerView.isHidden = true;
        
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    func textchanged(notif : NSNotification)
    {
        
        checkAvailableFormats(refresh)
    }
    

    
    
    @IBAction func chooseFormat(_ sender: NSButton) {
        
    
        
        if(sender.identifier == "mp4")
        {
            format = "mp4";
        }
        else if(sender.identifier == "webm")
        {
            format = "webm"
        }
        else if(sender.identifier == "flv")
        {
            format = "flv"
        }
        else if(sender.identifier == "mp3")
        {
            format = "mp3"
        }
        else
        {
            format = nil;
        }
       
        
    }
    
    
    @IBAction func toggleLog(_ sender: Any) {
        if(splitLowerView.isHidden)
        {
            splitLowerView.isHidden = false;
            splitView.adjustSubviews()
        }
        else
        {
            splitLowerView.isHidden = true;
            splitView.adjustSubviews()
        }

    }

    
    
    
    
    @IBAction func downloadvideo(_ sender: Any) {
        
        self.responseText.string! = "";
        self.progressPie.minValue = 0.0
        self.progressPie.maxValue = 100.0
        self.progressPie.doubleValue = 0.0
        
        
        DispatchQueue.global(qos: .background).async {
        
            self.progressIndicator.startAnimation(self)
            
            let task = Process()
            task.launchPath = self.youtubedlpath
            if(self.format != nil){
                
                if(self.format == "mp3")
                {
                task.arguments = ["-x", "--audio-format", "mp3", "--audio-quality","4", "-o", self.choosePath.stringValue + "/%(title)s.%(ext)s" ,"--ffmpeg-location", self.ffmpegpath, self.urlTextField.stringValue]
                    print("Get the AUDIO!")
                }
                else if(self.format == "mp4")
                {
                task.arguments = ["-f", "bestvideo[ext=\(self.format!)]+bestaudio[ext=m4a]/bestvideo+bestaudio", "--merge-output-format", "\(self.format!)", "-o", self.choosePath.stringValue + "/%(title)s.%(ext)s" ,"--ffmpeg-location", self.ffmpegpath, self.urlTextField.stringValue]
                    print("Get Your Format!: \(self.format)")
                }
                else
                {
                    task.arguments = ["-f", "bestvideo[ext=\(self.format!)]+bestaudio/bestvideo+bestaudio", "--merge-output-format", "\(self.format!)", "-o", self.choosePath.stringValue + "/%(title)s.%(ext)s" ,"--ffmpeg-location", self.ffmpegpath, self.urlTextField.stringValue]
                    print("Get Your Format!: \(self.format)")
                }
            }
            else
            {
                task.arguments = ["-o", self.choosePath.stringValue + "/%(title)s.%(ext)s","--ffmpeg-location" , self.ffmpegpath ,self.urlTextField.stringValue]
                print("Get the Best we HAVE!")
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

