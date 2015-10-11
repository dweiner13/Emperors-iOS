//
//  EmperorShareProvider.swift
//  emperors
//
//  Created by Daniel A. Weiner on 10/11/15.
//  Copyright © 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class EmperorShareProvider: UIActivityItemProvider {
    
    let mailHTMLString: String
    
    init(placeholderString: String, mailHTMLString: String) {
        self.mailHTMLString = mailHTMLString;
        
        super.init(placeholderItem: placeholderString);
    }
    
    override func item() -> AnyObject {
        if self.activityType == UIActivityTypeMail {
            return self.mailHTMLString;
        }
        else {
            return self.placeholderItem!;
        }
    }
}
