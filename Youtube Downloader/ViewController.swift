//
//  ViewController.swift
//  Youtube Downloader
//
//  Created by Philipp Dippel on 10.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    
    
    let bundle = Bundle.main
    var ffmpegpath : String = ""
    var youtubedlpath : String = ""
    var format : String?
    
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet var responseText: NSTextView!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var mainProgressBar: NSProgressIndicator!
    @IBOutlet weak var refresh: NSButton!
    @IBOutlet weak var choosePath: NSPathControl!
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var splitLowerView: NSView!
    
    
    //Radio Buttons Codec Types
    
    @IBOutlet weak var mp4Radio: NSButton!
    @IBOutlet weak var webmRadio: NSButton!
    @IBOutlet weak var flvRadio: NSButton!
    @IBOutlet weak var mp3Radio: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!

    
    //Cell Data
    var objects : NSMutableArray! = NSMutableArray()
    var tasks : NSMutableArray! = NSMutableArray()
    
    
    //MARK: -- Table View
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.objects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        let cellView = tableView.make(withIdentifier: "cell", owner: self) as! TableCell
        let celldata = self.objects.object(at: row) as! CellData
        
        cellView.textField!.stringValue = celldata.name
        
        if(celldata.image != nil){
        
            if(cellView.imageView?.image != #imageLiteral(resourceName: "cancel"))
            {
                cellView.imageView?.image = celldata.image
            }
        }
        
        cellView.progressBar.doubleValue = celldata.progress
        
        
        if(celldata.task != nil)
        {
            cellView.task = celldata.task as Process
        }
        
        cellView.index = celldata.index
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setTo100), name: NSNotification.Name.init("TimeToUpdate") , object: cellView)
        
        
        cellView.identifier = String(drand48())
        
        return cellView
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return false
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if(self.tableView.numberOfSelectedRows > 0){
        let selectetItem = self.objects.object(at: self.tableView.selectedRow) as! String
        
        print(selectetItem)
        
            self.tableView.deselectRow(self.tableView.selectedRow)
        }
    }
    
    
    
    
    func setTo100(notification : NSNotification)
    {
    
        if((notification.object as! TableCell).index != nil)
        {
            let index = (notification.object as! TableCell).index!
        
            (self.objects[index] as! CellData).progress = 100
            
            (self.objects[index] as! CellData).name = "Task Interrupted!"
            
            (self.objects[index] as! CellData).image = #imageLiteral(resourceName: "cancel")
            
            
        }
    updateMainBrogressbar()
    self.tableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        
        youtubedlpath = bundle.path(forResource: "youtube-dl", ofType: "")!
        ffmpegpath = bundle.path(forResource: "ffmpeg", ofType: "")!
        
        
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
    
        self.mainProgressBar.minValue = 0.0
        self.mainProgressBar.maxValue = 100.0
        self.mainProgressBar.doubleValue = 0.0
        
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        let window = self.view.window
        var rec: NSRect = (self.view.window?.frame)!
        
        rec.size = CGSize(width: 916, height: 290)
        window?.setFrame(rec, display: true, animate: true)

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
        
        let window = self.view.window
        var rec: NSRect = (self.view.window?.frame)!
        
        
        
        if(splitLowerView.isHidden)
        {
            rec.size = CGSize(width: 916, height: 526)
            splitLowerView.isHidden = false;
            splitView.adjustSubviews()
            //window?.setFrame(NSRect(x: x, y: y, width: 400, height: 400), display: true, animate: true)
            window?.setFrame(rec, display: true, animate: true)
        }
        else
        {
            rec.size = CGSize(width: 916, height: 290)

            
            splitLowerView.isHidden = true;
            splitView.adjustSubviews()
            window?.setFrame(rec, display: true, animate: true)
            
        }

    }

    
    
    
    
    @IBAction func downloadvideo(_ sender: Any) {
        
        let newCell = CellData()
        self.objects.add(newCell)
        
        var videotitel = ""
        var thumbnailurl = ""
        
        var indexOfNewElement = 0
        indexOfNewElement = self.objects.index(of: newCell)
        
        DispatchQueue.global(qos: .background).async {
          
            
            
            let task = Process()
            task.launchPath = self.youtubedlpath
            task.arguments = ["--get-title", self.urlTextField.stringValue]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            
            
            
            self.progressIndicator.startAnimation(self)
            let outHandle = pipe.fileHandleForReading
            outHandle.readabilityHandler =
                { pipe in
                    if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8)
                    {
                        videotitel = line
                    }
                    else{
                        
                        print("Error decoding data: \(pipe.availableData)")
                    }
                }
            task.launch()
            task.waitUntilExit()
            
            DispatchQueue.main.async
                {
                    
                    newCell.name = videotitel
                    
                    self.tableView.reloadData()
                }
            
            DispatchQueue.global(qos: .background).async {
                
                let thumbnailtask = Process()
                thumbnailtask.launchPath = self.youtubedlpath
                thumbnailtask.arguments = ["-q", "--get-thumbnail", self.urlTextField.stringValue]
                let thumbnailpipe = Pipe()
                thumbnailtask.standardOutput = thumbnailpipe
                thumbnailtask.standardError = thumbnailpipe
                
                let thumbnailOutHandle = thumbnailpipe.fileHandleForReading
                thumbnailOutHandle.readabilityHandler =
                    {
                        thumbnailpipe in
                        if let thumbnailline = String(data: thumbnailpipe.availableData, encoding: String.Encoding.utf8)
                        {
                            print(thumbnailline)
                            
                            if(thumbnailline.contains("http") == true){
                                thumbnailurl = thumbnailline
                            }
                        }
                        else
                        {
                        print("Error decoding data: \(thumbnailpipe.availableData)")
                        }
                }
                thumbnailtask.launch()
                thumbnailtask.waitUntilExit()
                
                DispatchQueue.main.async
                    {
                        
                        
                    print("ThumbnailURL: " + thumbnailurl)
                    let trimmedString = thumbnailurl.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        
                        
                    let url = URL(string: trimmedString)
                    
                    
                    
                        
                        if(url != nil)
                        {
                            print("URL: " + (url?.absoluteString)!)
                            print("Hallo")
                            let data = try? Data(contentsOf: url!)
                            let image = NSImage(data: data!)
                            
                            (self.objects[indexOfNewElement] as! CellData).image = image
                 
                            
                        }
                        self.tableView.reloadData()
                }
                
            }
            
        }
        
        self.responseText.string! = "";
        
        
        
        DispatchQueue.global(qos: .background).async {
        
            self.progressIndicator.startAnimation(self)
            
            let task = Process()
            task.launchPath = self.youtubedlpath
            
            
            ///
            
            
         
            (self.objects[indexOfNewElement] as! CellData).task = task
            (self.objects[indexOfNewElement] as! CellData).index = indexOfNewElement
            
            
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
            
            task.terminationHandler =
                {
                    task in
                    DispatchQueue.main.async(execute: {
                        outHandle.closeFile()
                        
                    })
            
            }
            
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
                                            (self.objects[indexOfNewElement] as! CellData).progress = myDouble!
                                            
                                            self.tableView.reloadData()
                                            
                                            self.updateMainBrogressbar()
                                            
                                        }
                                    }
                                }
                                
                                if(line.contains("already been downloaded"))
                                {
                                    (self.objects[indexOfNewElement] as! CellData).progress = 100;
                                    (self.objects[indexOfNewElement] as! CellData).name = (self.objects[indexOfNewElement] as! CellData).name + "-- already been downloaded"
                                    
                                    self.tableView.reloadData()
                                }

                                
                                
                                
                                
                        }
                    }
                    else {
                        print("Error decoding data: \(pipe.availableData)")
                    }
            }
            task.launch()
            //task.waitUntilExit()
            
            
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
    
    func updateMainBrogressbar()
    {
        var sum = 0.0
        
        for x in objects
        {
          sum += (x as! CellData).progress
        }
        
        sum = sum/Double(objects.count)
        
        mainProgressBar.doubleValue = sum
        
        if(mainProgressBar.doubleValue >= 100)
        {
        NSSound.init(named: "Ping")?.play()
        }
        
    }
    
    
}

