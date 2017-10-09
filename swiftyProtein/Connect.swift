//
//  Connect.swift
//  swiftyProtein
//
//  Created by sebastien pariaud on 03/10/2017.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import Foundation
import UIKit

class Connect {
    var currentAtom: Atom
    var atomTarget: Atom
    var isDouble: Bool
    var isAromaticFlag: Bool
    var color: UIColor = UIColor.white
    var height: Float = 0.0
    var heightIdeal: Float = 0.0
    
    init(pcurrentAtom: Atom, patomTarget: Atom, pisDouble: String, pisAromaticFlag: String) {
        
        self.currentAtom = pcurrentAtom
        self.atomTarget = patomTarget
        self.isDouble = (pisDouble == "DOUB")
        self.isAromaticFlag = (pisAromaticFlag == "Y")
        self.height = self.getDistance(a1: self.currentAtom, a2: self.atomTarget) / 2.0
        self.heightIdeal = self.getDistance(a1: self.currentAtom, a2: self.atomTarget) / 2.0
        self.color = (self.isAromaticFlag) ? currentAtom.color : UIColor(displayP3Red: 255, green: 192, blue: 203, alpha: 1)
    }
    
    private func getDistance(a1: Atom, a2: Atom) -> Float {
        let xd = a2.x - a1.x
        let yd = a2.y - a1.y
        let zd = a2.z - a1.z
        let dist = Float(sqrt(xd * xd + yd * yd + zd * zd))
        if (dist < 0) {
            return (dist * -1)
        } else {
            return dist
        }
    }
    
    private func getDistanceIdeal(a1: Atom, a2: Atom) -> Float {
        let xdide = a2.xide - a1.xide
        let ydide = a2.yide - a1.yide
        let zdide = a2.zide - a1.zide
        let dist = Float(sqrt(xdide * xdide + ydide * ydide + zdide * zdide))
        if (dist < 0) {
            return (dist * -1)
        } else {
            return dist
        }
    }

}
