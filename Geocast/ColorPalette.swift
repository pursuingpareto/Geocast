//
//  ColorPalette.swift
//  Geocast
//
//  Created by Andrew Brown on 11/30/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

let SelectedThemeKey = "SelectedTheme"
enum Theme : Int {
    case Default, Dark, Graphical
    
    var primaryColors : [UIColor] {
        return [
            UIColor(netHex: 0xF5DEE2),
            UIColor(netHex: 0xDE9CA8),
            UIColor(netHex: 0xB0495B),
            UIColor(netHex: 0x620213),
        ]
    }
    
    var complentaryColors : [UIColor] {
        return [
            UIColor(netHex: 0xDAE9D3),
            UIColor(netHex: 0xA1CC8F),
            UIColor(netHex: 0x5FA143),
            UIColor(netHex: 0x1C5A02),
        ]
    }
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 255.0/255.0, green: 116.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        case .Graphical:
            return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        }
    }
}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = NSUserDefaults.standardUserDefaults().valueForKey(SelectedThemeKey)?.integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Default
        }
    }
    
    static func applyTheme(theme: Theme) {
        // 1
        NSUserDefaults.standardUserDefaults().setValue(theme.rawValue, forKey: SelectedThemeKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // 2
        let sharedApplication = UIApplication.sharedApplication()
        let sharedWindow = sharedApplication.delegate?.window
        sharedWindow??.tintColor = theme.primaryColors[2]
//        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        UINavigationBar.appearance().barTintColor = theme.primaryColors[0]
        UITabBar.appearance().barTintColor = theme.primaryColors[0]
//        UITableView.appearance().backgroundColor = theme.primaryColors[3]
//        UITableViewCell.appearance().backgroundColor = theme.primaryColors[0]
//        UITableViewCell.appearance().tintAdjustmentMode
        UIButton.appearance().setTitleColor(theme.primaryColors[2], forState: .Normal)
        UIButton.appearance().setTitleColor(theme.primaryColors[1], forState: .Disabled)
        UIButton.appearance().setTitleColor(theme.primaryColors[3], forState: .Highlighted)
    }
}