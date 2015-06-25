//
//  ViewController.swift
//  StoreInSwift
//
//  Created by thienle on 6/23/15.
//  Copyright (c) 2015 thienle. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        tableView.rowHeight = 80
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        var entityName: String
        switch category {
            case 1: entityName = "musicTrack"
            case 2: entityName = "software"
            case 3: entityName = "ebook"
        default: entityName = ""
        }
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
            
        return url!
    }
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
        var error: NSError?
        if let resultString = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
            return resultString
        } else if let error = error {
            println("Download Error: \(error)")
        } else {
            println("Unknown Dowload Error")
        }
        return nil
    }
    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        } else if let error = error {
            println("JSON Error: \(error)")
        } else {
            println("Unknow JSON Error")
        }
        return nil
    }
    
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        
        var searchResults = [SearchResult]()
        
        // 1
        if let array: AnyObject = dictionary["results"] {
            // 2
            for resultDict in array as! [AnyObject] {
                // 3
                if let resultDict = resultDict as? [String: AnyObject] {
                    var searchResult: SearchResult?
                    // 4
                    if let wrapperType = resultDict["wrapperType"] as? NSString {
                        switch wrapperType {
                            case "track":
                                searchResult = parseTrack(resultDict)
                            case "audiobook":
                                searchResult = parseAudioBook(resultDict)
                            case "sofware":
                                searchResult = parseSoftware(resultDict)

                            default:
                                break
                        }
                    } else if let kind = resultDict["kind"] as? String {
                        if kind == "ebook" {
                            searchResult = parseEBook(resultDict)
                        }
                    }
                    
                    if let result = searchResult {
                        searchResults.append(result)
                    }
                    // 5
                } else {
                    println("Expected a dictionary")
                }
            }
        } else {
            println("Expected 'results' array")
        }
        return searchResults
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message:
            "There was an error reading from the iTunes Store. Please try again.",
            preferredStyle: .Alert
        )
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
            searchResult.artworkURL100 = dictionary["artworkUrl100"] as! NSString as String
            searchResult.storeURL = dictionary["trackViewUrl"] as! NSString as String
            searchResult.kind = dictionary["kind"] as! NSString as String
            searchResult.currency = dictionary["currency"] as! NSString as String
            if let price = dictionary["trackPrice"] as? NSNumber {
            searchResult.price = Double(price)
            }
            if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre as String
            }
        return searchResult
    }
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
                let searchResult = SearchResult()
                searchResult.name = dictionary["collectionName"] as! String
                searchResult.artistName = dictionary["artistName"] as! String
                searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
                searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
                searchResult.storeURL = dictionary["collectionViewUrl"] as! String
                searchResult.kind = "audiobook"
                searchResult.currency = dictionary["currency"] as! String
                if let price = dictionary["collectionPrice"] as? NSNumber {
                    searchResult.price = Double(price)
                }
                if let genre = dictionary["primaryGenreName"] as? String {
                    searchResult.genre = genre
                }
                return searchResult
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
                let searchResult = SearchResult()
                searchResult.name = dictionary["trackName"] as! String
                searchResult.artistName = dictionary["artistName"] as! String
                searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
                searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
                searchResult.storeURL = dictionary["trackViewUrl"] as! String
                searchResult.kind = dictionary["kind"] as! String
                searchResult.currency = dictionary["currency"] as! String
                if let price = dictionary["price"] as? NSNumber {
                    searchResult.price = Double(price)
                }
                if let genre = dictionary["primaryGenreName"] as? String {
                    searchResult.genre = genre
                }
                    return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
        performSearch()
    }


    func performSearch() {
        if !searchBar.text.isEmpty {
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            hasSearched = true
            searchResults = [SearchResult]()
            ////            let url = urlWithSearchText(searchBar.text)
            ////
            ////            println("URL: \(url)")
            ////            if let jsonString = performStoreRequestWithURL(url) {
            ////
            ////                if let dictionary = parseJSON(jsonString) {
            ////
            ////                    searchResults = parseDictionary(dictionary)
            ////
            //////                    searchResults.sort{ $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
            //////                    searchResults.sort({result1, result2 in
            //////                                            return result1.name.localizedStandardCompare(result2.name) ==
            //////                                                NSComparisonResult.OrderedAscending
            //////                                        })
            //////                    searchResults.sort{ $0 < $1 }
            ////                    searchResults.sort(<)
            ////                    isLoading = false
            ////                    tableView.reloadData()
            ////                    return
            ////                }
            ////
            ////            }
            ////            showNetworkError()
            //
            ////            ******************ASYNCHRONOUS******************
            //            // 1
            //            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            //
            //            // 2
            //
            //            dispatch_async(queue, { () -> Void in
            //                let url = self.urlWithSearchText(searchBar.text)
            //                if let jsonString = self.performStoreRequestWithURL(url) {
            //                    if let dictionary = self.parseJSON(jsonString) {
            //                        self.searchResults = self.parseDictionary(dictionary)
            //                        self.searchResults.sort(<)
            //
            //                        // 3
            //                        println("DONE!")
            //                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //                            self.isLoading = false
            //                            self.tableView.reloadData()
            //                        })
            //
            //                        return
            //                    }
            //                }
            //                println("ERROR")
            //                dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //                        self.showNetworkError()
            //                })
            //
            //            })
            
            ////////NSURLSession
            // 1
            let url = self.urlWithSearchText(searchBar.text, category: segmentedControl.selectedSegmentIndex)
            // 2
            let session = NSURLSession.sharedSession()
            // 3
            dataTask = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                //4
                if let error = error {
                    println("Failure! \(error)")
                    if error.code == -999 {return}
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data) {
                            self.searchResults = self.parseDictionary(dictionary)
                            self.searchResults.sort(<)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.isLoading = false
                                self.tableView.reloadData()
                            })
                        }
                    } else {
                        println("Failure! \(response)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.hasSearched = false
                            self.isLoading = false
                            self.tableView.reloadData()
                            self.showNetworkError()
                        })
                    }
                }
            })
            
            dataTask?.resume()
            
        }
    }


}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
        performSearch()

    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count > 0 {
            return searchResults.count
        } else {
            return 1
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIndenfitier = TableViewCellIdentifiers.searchResultCell
    
        
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! UITableViewCell
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        if searchResults.count == 0 {
        return tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIndenfitier, forIndexPath: indexPath) as! SearchResultCell
        
            let searchResult = searchResults[indexPath.row]
            
            cell.configureForSearchResult(searchResult)
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading  {
            return nil
        } else {
            return indexPath
        }
    }
}