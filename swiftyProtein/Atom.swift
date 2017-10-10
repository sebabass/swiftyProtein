//
//  Atom.swift
//  swiftyProtein
//
//  Created by sebastien pariaud on 13/02/2017.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class Atom {
    
    var id: String
    var x: Float
    var y: Float
    var z: Float
    var xide: Float
    var yide: Float
    var zide: Float
    var type: String
    var color: UIColor = UIColor.white
    var connects: [Connect] = []
    var connect: [Int] = []
    var isAromatiqFlag: Bool
    var node: SCNNode = SCNNode()
    
    init(pid: String, ptype: String, px: Float, py: Float, pz: Float, pxide: Float, pyide: Float, pzide: Float, pisAromatiqFlag: String) {
        self.id = pid
        self.x = px
        self.y = py
        self.z = pz
        self.xide = pxide
        self.yide = pyide
        self.zide = pzide
        self.type = ptype
        self.isAromatiqFlag = (pisAromatiqFlag == "Y")
        self.color = getColorCPK(type: ptype)
    }

    // Color CPK
    func getColorCPK(type: String) -> UIColor {
        switch (type.uppercased()) {
        case "H":
            return UIColor.white
        case "C":
            return UIColor.gray
        case "N":
            return UIColor(displayP3Red: 0, green: 0, blue: 139, alpha: 1)
        case "O":
            return UIColor.red
        case "F", "CL":
            return UIColor.green
        case "BR":
            return UIColor(displayP3Red: 139, green: 0, blue: 0, alpha: 1)
        case "I":
            return UIColor(displayP3Red: 148, green: 0, blue: 211, alpha: 1)
        case "HE", "NE", "AR", "XE", "KR":
            return UIColor.cyan
        case "P":
            return UIColor.orange
        case "S":
            return UIColor.yellow
        case "B":
            return UIColor(displayP3Red: 250, green: 128, blue: 114, alpha: 1)
        case "LI", "NA", "K", "RB", "CA", "FR":
            return UIColor.purple
        case "BE", "MG", "CA", "SR", "BA", "RA":
            return UIColor(displayP3Red: 0, green: 100, blue: 0, alpha: 1)
        case "TI":
            return UIColor.gray
        case "FE":
            return UIColor(displayP3Red: 255, green: 140, blue: 0, alpha: 1)
        default:
            return UIColor(displayP3Red: 255, green: 192, blue: 203, alpha: 1)
        }
    }

}
