//
//  ViewController.swift
//  StoreInSwift
//
//  Created by thienle on 6/23/15.
//  Copyright (c) 2015 thienle. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchReslults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchReslults = [String]()
        for i in 0...2 {
            searchReslults.append(String(format: "Fake Result %d for %@", i, searchBar.text))
        }
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchReslults.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIndenfitier = "SearchResultCell"
    
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIndenfitier) as! UITableViewCell
    
        if cell == cell {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIndenfitier)
        }
    
        cell.textLabel!.text = searchReslults[indexPath.row]
    
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
            
}