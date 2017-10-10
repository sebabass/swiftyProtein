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
    
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var infosButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var proteinType: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var isHydrogenButton: CheckBox!
    @IBOutlet weak var isAutoRotate: CheckBox!
    @IBOutlet weak var isLabel: CheckBox!
    @IBOutlet weak var LigandId: UINavigationItem!
    
    var scene : SCNScene!
    var cameraNode : SCNNode!
    var ligandNode: SCNNode!
    var linesFile: [String] = []
    var atoms: [Atom] = []
    var ligand = ""
    var gestureReconizer: UITapGestureRecognizer!
    var ligandTest: Ligand!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initMenu()
        self.ligandTest = Ligand(pid: ligand)
        self.ligandTest.load(pview: self)
        self.scene = SCNScene()
        self.gestureReconizer = UITapGestureRecognizer(target: self, action: #selector(testGesture))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.popViewController(animated: true)
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
        for atom in self.ligandTest.atoms {
            if (atom.node == node) {
                proteinType.text = atom.type + "(" + atom.id + ")"
            }
        }
    }
    
    func initMenu() {
        // Menu Button
        menuButton.backgroundColor = .clear
        menuButton.layer.cornerRadius = 5
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = UIColor.black.cgColor
        
        // Infos Button
        infosButton.backgroundColor = .clear
        infosButton.layer.cornerRadius = 5
        infosButton.layer.borderWidth = 1
        infosButton.layer.borderColor = UIColor.black.cgColor
        infosButton.isHidden = true
        
        // Share Button
        shareButton.backgroundColor = .clear
        shareButton.layer.cornerRadius = 5
        shareButton.layer.borderWidth = 1
        shareButton.layer.borderColor = UIColor.black.cgColor
        shareButton.isHidden = true
        
    }
    
    @IBAction func OpenOrCloseMenu(_ sender: UIButton) {
        if (infosButton.isHidden) {
            infosButton.isHidden = false
            shareButton.isHidden = false
        } else {
            infosButton.isHidden = true
            shareButton.isHidden = true
        }
    }
    
    @IBAction func OnShare(_ sender: UIButton) {
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func OpenInfosPopup(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopupViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.contents.append(ligandTest.name)
        vc.contents.append(ligandTest.type)
        vc.contents.append(ligandTest.formula)
        vc.contents.append(ligandTest.formulaWeight)
        vc.contents.append(String(ligandTest.nbrAtoms))
        vc.contents.append(String(ligandTest.nbrConnects))
        vc.id = ligand
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func load() {
        DispatchQueue.main.async {
            // create and add a camera to the scene
            self.cameraNode = SCNNode()
            self.cameraNode.camera = SCNCamera()
            self.scene.rootNode.addChildNode(self.cameraNode)
            
            // place the camera
            self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            
            self.sceneView.scene = self.scene
            self.sceneView.allowsCameraControl = true
            self.sceneView.autoenablesDefaultLighting = true
            
            self.ligandNode = SCNNode()
            self.drawAtoms()
            self.scene.rootNode.addChildNode(self.ligandNode)
            self.centerPivot(for: self.ligandNode)
            self.sceneView.addGestureRecognizer(self.gestureReconizer)
            self.LigandId.title = self.ligandTest.id
        }
    }
    
    func drawAtoms() {
        ligandTest.nbrConnects = 0
        for atom in self.ligandTest.atoms {
            if (atom.type != "H" || atom.type == "H" && isHydrogenButton.isChecked) {
                
                let sphere = SCNSphere(radius: 0.3)
                sphere.firstMaterial?.diffuse.contents = atom.color
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3Make(atom.x, atom.y, atom.z)
                ligandNode.addChildNode(sphereNode)
                
                if (isLabel.isChecked) {
                    let text = SCNText(string: atom.id, extrusionDepth: 2.0)
                    text.firstMaterial?.diffuse.contents = UIColor.black
                    let textNode = SCNNode(geometry: text)
                    textNode.position = sphereNode.position
                    textNode.position.x -= 0.2
                    textNode.position.y += 0.2
                    textNode.scale = SCNVector3Make(0.04, 0.04, 0.04);
                    ligandNode.addChildNode(textNode)
                }
                atom.node = sphereNode
            }
        }
        for atom in self.ligandTest.atoms {
            if (atom.type != "H" || atom.type == "H" && isHydrogenButton.isChecked) {
                drawConnects(atom: atom)
            }
        }
    }
    
    func drawConnects(atom: Atom) {
        for connect in atom.connects {
            ligandTest.nbrConnects += 1
            if (connect.atomTarget.type != "H" || connect.atomTarget.type == "H" && isHydrogenButton.isChecked) {
                ligandNode.addChildNode(lineNode(connect: connect))
            }
        }
    }
    
    func lineNode(connect: Connect) -> SCNNode {
        let a1: Atom = connect.currentAtom
        let a2: Atom = connect.atomTarget

        let ret = SCNNode()
        let height = connect.height
        
        ret.position = a1.node.position
        let nodev2 = a2.node
        
        ligandNode.addChildNode(nodev2)
        let zalign = SCNNode()
        zalign.eulerAngles.x = Float(Double.pi / 2)
        let cyl = (connect.isDouble) ? SCNCylinder(radius: 0.05, height: CGFloat(height)) : SCNCylinder(radius: 0.1, height: CGFloat(height))
        cyl.firstMaterial?.diffuse.contents = a1.color
        let cyl2 = (connect.isDouble) ? SCNCylinder(radius: 0.05, height: CGFloat(height)) : SCNCylinder(radius: 0.1, height: CGFloat(height))
        cyl2.firstMaterial?.diffuse.contents = a2.color
        let cyl3 = SCNCylinder(radius: 0.05, height: CGFloat(height))
        cyl3.firstMaterial?.diffuse.contents = a1.color
        let cyl4 = SCNCylinder(radius: 0.05, height: CGFloat(height))
        cyl4.firstMaterial?.diffuse.contents = a2.color
        
        let cylNode = SCNNode(geometry: cyl)
        cylNode.position.y = -height / 2
        let cylNode2 = SCNNode(geometry: cyl2)
        cylNode2.position.y = (-height + (-height / 2))
        zalign.addChildNode(cylNode)
        zalign.addChildNode(cylNode2)
        
        if (connect.isDouble) {
            let cylNode3 = SCNNode(geometry: cyl3)
            cylNode3.position.y = -height / 2
            let cylNode4 = SCNNode(geometry: cyl4)
            cylNode4.position.y = (-height + (-height / 2))
            cylNode.position.x = -0.1
            cylNode2.position.x = -0.1
            cylNode3.position.x = 0.1
            cylNode4.position.x = 0.1
            zalign.addChildNode(cylNode3)
            zalign.addChildNode(cylNode4)
        }
        
        ret.addChildNode(zalign)
        ret.constraints = [SCNLookAtConstraint(target: nodev2)]
        return ret
    }
    
    @IBAction func isHydrogen(_ sender: CheckBox) {
        isAutoRotate.isChecked = false
        self.scene.rootNode.enumerateChildNodes { (node, stop )  -> Void in
            node.removeFromParentNode()
        }
        self.load()
    }
    
    @IBAction func isRotate(_ sender: CheckBox) {
        if (!isAutoRotate.isChecked) {
            self.ligandNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)))
        } else {
            self.ligandNode.removeAllActions()
        }
    }
    
    @IBAction func isLabel(_ sender: CheckBox) {
        isAutoRotate.isChecked = false
        self.scene.rootNode.enumerateChildNodes { (node, stop )  -> Void in
            node.removeFromParentNode()
        }
        self.load()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
}
