//
//  WindowController.swift
//  Pillager
//
//  Created by Philipp Dippel on 16.01.17.
//  Copyright © 2017 Philipp Dippel. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        let userAppearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        
        if(userAppearance == "Dark")
        {
        self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        }
        else
        {
        self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        }
        
        
        
        self.window?.invalidateShadow()
        self.window?.titlebarAppearsTransparent = true
        
    }

}
