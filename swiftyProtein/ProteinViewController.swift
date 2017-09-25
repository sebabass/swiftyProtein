//
//  ProteinViewController.swift
//  swiftyProtein
//
//  Created by sebastien pariaud on 13/02/2017.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import UIKit
import SceneKit

class ProteinViewController : UIViewController {
    
    @IBOutlet weak var proteinType: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    var scene : SCNScene!
    var cameraNode : SCNNode!
    var linesFile: [String] = []
    var atoms: [Atom] = []
    var ligand = ""
    var gestureReconizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        self.gestureReconizer = UITapGestureRecognizer(target: self, action: #selector(testGesture))
    }
    
    func testGesture(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResult = sceneView.hitTest(location, options: nil)
        if (hitResult.count > 0) {
            let result = hitResult[0] as SCNHitTestResult
            let node = result.node
            if (node.geometry?.isMember(of: SCNSphere.self))! {
                getProtein(node: node)
            }
        }
    }
    
    func getProtein(node: SCNNode) {
        for atom in atoms {
            if (atom.node == node) {
                proteinType.text = atom.type
            }
        }
    }
    
    func load() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("\(ligand) => ligand")
        let url = NSURL(string: "https://files.rcsb.org/ligands/view/\(ligand)_model.pdb")
        let task = URLSession.shared.dataTask(with: url! as URL) {
            (data, response, error) in
            if error == nil {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode >= 200 && response.statusCode <= 299 {
                        DispatchQueue.main.async {
                            let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!
                            let string = urlContent! as String
                            self.linesFile = string.components(separatedBy: "\n")
                            self.scene = SCNScene()
                            
                            self.cameraNode = SCNNode()
                            self.cameraNode.camera = SCNCamera()
                            self.scene.rootNode.addChildNode(self.cameraNode)
                            self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
                            
                            self.sceneView.scene = self.scene
                            self.sceneView.allowsCameraControl = true
                            self.sceneView.autoenablesDefaultLighting = true
                            
                            self.sceneView.addGestureRecognizer(self.gestureReconizer)
                            
                            self.parse()
                            self.drawAtoms()
                        }
                    } else {
                        
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Error", message: "Can't load Ligand", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "GOTCHA", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Can't load Ligand", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "GOTCHA", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        task.resume()
    }
    
    func parse() {
        let regex = try! NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.caseInsensitive)
        for line in linesFile {
            let range = NSMakeRange(0, line.characters.count)
            let nstr = regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "|")
            let split = nstr.components(separatedBy: "|")
            if (split.count > 0) {
                switch (split[0]) {
                    case "ATOM":
                        createAtom(split: split)
                    break
                    case "CONECT":
                        addConnect(split: split)
                    break
                    case "END":
                        return
                    default:
                        // error
                        return
                }
            }
        }
    }
    
    func createAtom(split: [String]) {
        if (split.count < 12) {
            //error
            return
        }
        let atom = Atom(px: Float(split[6])!, py: Float(split[7])!, pz: Float(split[8])!, ptype: split[11])
        self.atoms.append(atom)
    }
    
    func addConnect(split: [String]) {
        if (split.count < 3) {
            // error
            return
        }
        let atomId = Int(split[1])
        if (self.atoms.count < atomId!) {
            // error
            return
        }
        for i in 2...(split.count - 1) {
            if (Int(split[i]) != atomId) {
                self.atoms[atomId! - 1].connect.append(Int(split[i])!)
            }
        }
    }
    
    func drawAtoms() {
        for atom in self.atoms {
            let sphere = SCNSphere(radius: 0.3)
            sphere.firstMaterial?.diffuse.contents = atom.color
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(atom.x, atom.y, atom.z)
            scene.rootNode.addChildNode(sphereNode)
            atom.node = sphereNode
        }
        for atom in self.atoms {
            drawConnects(atom: atom)
        }
    }
    
    func drawConnects(atom: Atom) {
        for connect in atom.connect {
            if (connect <= self.atoms.count) {
                scene.rootNode.addChildNode(lineNode(a1: atom, a2: self.atoms[connect - 1]))
            }
        }
    }
    
    func lineNode(a1:Atom, a2: Atom) -> SCNNode {
        let ret = SCNNode()
        let height = getDist(a1: a1, a2: a2)
        
        ret.position = a1.node.position
        let nodev2 = a2.node
        
        scene.rootNode.addChildNode(nodev2)
        let zalign = SCNNode()
        zalign.eulerAngles.x = Float(Double.pi / 2)
        let cyl = SCNCylinder(radius: 0.1, height: CGFloat(height))
        cyl.firstMaterial?.diffuse.contents = UIColor.gray
        
        let cylNode = SCNNode(geometry: cyl)
        cylNode.position.y = -height / 2
        zalign.addChildNode(cylNode)
        
        ret.addChildNode(zalign)
        ret.constraints = [SCNLookAtConstraint(target: nodev2)]
        return ret
    }
    
    func getDist(a1:Atom, a2: Atom) -> Float {
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
    
    // add alert error
}
