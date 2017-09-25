//
//  ProteinListViewController.swift
//  swiftyProtein
//
//  Created by sebastien pariaud on 10/02/2017.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import UIKit
import Foundation

class ProteinListViewController: UITableViewController {

    var proteinsList: [String]!
    var proteinsSearchList: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)


    func filterContentForSearchText(searchText: String, scope: String = "All") {
        proteinsSearchList = proteinsList.filter { str in
            return str.localizedLowercase.contains(searchText.localizedLowercase)
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.proteinsList = readFile(path: "ligands")
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func readFile(path: String) -> Array<String> {
        if let filepath = Bundle.main.path(forResource: path, ofType: "txt")
        {
            do
            {
                let contents = try String(contentsOfFile: filepath)
                var lines = contents.components(separatedBy: "\n")
                lines.remove(at: lines.count - 1)
                return lines
            }
            catch
            {
                print("Unable to read file: \(path)");
                return [String]()
            }
        }
        else
        {
            print("Unable to read file: \(path)");
            return [String]()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive && searchController.searchBar.text != "") {
            return proteinsSearchList.count
        }
        return proteinsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LigandIdentifier") as! LigandTableViewCell
        if (searchController.isActive && searchController.searchBar.text != "") {
            cell.Ligand.text = proteinsSearchList[indexPath.row]
        } else {
            cell.Ligand.text = proteinsList[indexPath.row]
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ligandSegue" {
            if let destination = segue.destination as? ProteinViewController {
                let path = tableView.indexPathForSelectedRow
                let cell = tableView.cellForRow(at: path!) as! LigandTableViewCell
                destination.ligand = cell.Ligand.text!
            }
        }
    }
    
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRow(at: indexPath) {
            self.performSegue(withIdentifier: "ligandSegue", sender: self.view)
        }
    }*/
}

extension ProteinListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
