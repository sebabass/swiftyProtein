//
//  PopupViewController.swift
//  swiftyProtein
//
//  Created by Sebastien PARIAUD on 10/10/17.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import Foundation
import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var ligandIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInfosLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var timer: Timer!
    var updaterCount: Int!
    var id: String = ""
    let titles: [String] = ["Name", "Type", "Formula", "Formula weight", "Atom count", "Bound count"]
    var contents: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popup.layer.cornerRadius = 15
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOffset = CGSize(width: 0, height: 10)
        popup.layer.shadowOpacity = 0.9
        popup.layer.shadowRadius = 5
        
        ligandIdLabel.text = id
        ligandIdLabel.layer.bounds = CGRect()
        ligandIdLabel.layer.cornerRadius = 15
        ligandIdLabel.layer.borderColor = UIColor.black.cgColor
        ligandIdLabel.layer.borderWidth = 2
        
        updaterCount = 0
        updateContent()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(PopupViewController.updaterTime), userInfo: nil, repeats: true)
    }
    
    func updateContent() {
        titleLabel.text = titles[updaterCount]
        textInfosLabel.text = contents[updaterCount]
    }
    
    internal func updaterTime() {
        if (updaterCount == -1) {return}
        if (updaterCount <= titles.count - 1) {
            pageControl.currentPage = updaterCount
            updateContent()
            updaterCount = updaterCount + 1
        } else {
            updaterCount = 0
        }
    }
    
    @IBAction func changePage(_ sender: UIPageControl) {
        updaterCount = sender.currentPage
        pageControl.currentPage = updaterCount
        updateContent()
    }
    
    @IBAction func ok(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.updaterCount = -1
        }
    }
    
}
