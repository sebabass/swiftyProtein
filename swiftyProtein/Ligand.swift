//
//  Ligand.swift
//  swiftyProtein
//
//  Created by sebastien pariaud on 02/10/2017.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import Foundation
import UIKit

class Ligand {
    
    // Infos
    var id: String
    var name: String = ""
    var type: String = ""
    var pdbxType: String = ""
    var formula: String = ""
    var formulaWeight: String = ""
    var nbrAtoms: Int = 0
    var nbrConnects: Int = 0
    
    // Atoms
    var atoms: [Atom]
    
    init(pid: String) {
        self.id = pid
        atoms = []
    }
    
    func load(pview: ProteinViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = NSURL(string: "https://files.rcsb.org/ligands/view/\(self.id).cif")
        let task = URLSession.shared.dataTask(with: url! as URL) {
            (data, response, error) in
            if error == nil {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode >= 200 && response.statusCode <= 299 {
                        DispatchQueue.main.async {
                            let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!
                            let string = urlContent! as String
                            let resultFile = string.components(separatedBy: "\n")
                            self.parse(presultFile: resultFile)
                            pview.load()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Can't load Ligand", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "GOTCHA", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        pview.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: "Can't load Ligand", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "GOTCHA", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    pview.present(alertController, animated: true, completion: nil)
                }
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        task.resume()
    }
    
    func debugTest() {
        print(self.id)
        print(self.name)
        print(self.type)
        print(self.pdbxType)
        print(self.formula)
        print(self.formulaWeight)
    }
    
    private func parse(presultFile: [String]) {
        var step: Int = 0
        for var i in 0 ..< presultFile.count {
            if (presultFile[i].trimmingCharacters(in: .whitespacesAndNewlines) == "#") {
                switch (step) {
                case 0:
                    i = self.parseInfos(presultFile: presultFile, pi: (i + 1))
                    step += 1
                    break
                case 1:
                    i = self.parseAtoms(presultFile: presultFile, pi: (i + 1))
                    self.nbrAtoms = self.atoms.count
                    step += 1
                    break
                case 2:
                    i = self.parseConnects(presultFile: presultFile, pi: (i + 1))
                    step += 1
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func parseInfos(presultFile: [String], pi: Int) -> Int {
        let regex = try! NSRegularExpression(pattern: "\\s{2,}", options: NSRegularExpression.Options.caseInsensitive)
        var i: Int = pi
        while (presultFile[i].trimmingCharacters(in: .whitespacesAndNewlines) != "#") {
            let range = NSMakeRange(0, presultFile[i].characters.count)
            let nstr = regex.stringByReplacingMatches(in: presultFile[i], options: [], range: range, withTemplate: "|")
            let split = nstr.components(separatedBy: "|")
            switch (split[0]) {
            case "_chem_comp.name":
                self.name = split[1]
                break
            case "_chem_comp.type":
                self.type = split[1]
                break
            case "_chem_comp.pdbx_type":
                self.pdbxType = split[1]
                break
            case "_chem_comp.formula":
                self.formula = split[1]
                break
            case "_chem_comp.formula_weight":
                self.formulaWeight = split[1]
                break
            default:
                break
            }
            i += 1
        }
        return (i - 1)
    }
    
    private func parseAtoms(presultFile: [String], pi: Int) -> Int {
        let regex = try! NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.caseInsensitive)
        var i: Int = pi
        while (presultFile[i].trimmingCharacters(in: .whitespacesAndNewlines) != "#") {
            let range = NSMakeRange(0, presultFile[i].characters.count)
            let nstr = regex.stringByReplacingMatches(in: presultFile[i], options: [], range: range, withTemplate: "|")
            let split = nstr.components(separatedBy: "|")
            if (split[0] == self.id && split[9] != "?" && split[10] != "?" && split[11] != "?") {
                let atom = Atom(pid: split[1], ptype: split[3], px: Float(split[9])!, py: Float(split[10])!, pz: Float(split[11])!, pxide: Float(split[12])!, pyide: Float(split[13])!, pzide: Float(split[14])!, pisAromatiqFlag: split[6])
                self.atoms.append(atom)
            }
            i += 1
        }
        return (i - 1)
    }
    
    private func parseConnects(presultFile: [String], pi: Int) -> Int {
        let regex = try! NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.caseInsensitive)
        var i: Int = pi
        while (presultFile[i].trimmingCharacters(in: .whitespacesAndNewlines) != "#") {
            let range = NSMakeRange(0, presultFile[i].characters.count)
            let nstr = regex.stringByReplacingMatches(in: presultFile[i], options: [], range: range, withTemplate: "|")
            let split = nstr.components(separatedBy: "|")
            if (split[0] == self.id) {
                let currentAtom = searchAtomById(pid: split[1])
                let atomTarget = searchAtomById(pid: split[2])
                let connect = Connect(pcurrentAtom: currentAtom, patomTarget: atomTarget, pisDouble: split[3], pisAromaticFlag: split[4])
                currentAtom.connects.append(connect)
            }
            i += 1
        }
        return (i - 1)
    }
    
    private func searchAtomById(pid: String) -> Atom {
        if let i = self.atoms.index(where: { $0.id == pid }) {
            return self.atoms[i]
        }
        return self.atoms[0]
    }
}
