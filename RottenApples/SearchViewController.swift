//
//  SearchViewController.swift
//  RottenApples
//
//  Created by Ming Horn on 6/15/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class SearchViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {

    
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //Optional in case the request doesn't work or doesn't give a response
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]?
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        tableView.dataSource = self
        
        //Initialize a new refresh control instance
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //Show HUD before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        sendRequest("hud", refreshControl: nil)
        
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        
        // By default the navigation bar hides when presenting the
        // search interface.  Obviously we don't want this to happen if
        // our search bar is inside the navigation bar.
        searchController.hidesNavigationBarDuringPresentation = false
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense. Should probably only set
        // this to yes if using another controller to display the search results.
        searchController.dimsBackgroundDuringPresentation = false
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if movies returned data return the length, otherwise return 0 because it can't be nil
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultsCell", forIndexPath: indexPath) as! ResultsCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let bkgPath = movie["backdrop_path"] as? String
        if(bkgPath != nil) {
            cell.backgroundImg.hidden = false
            let baseUrl = "https://image.tmdb.org/t/p/w342"
            let imgUrl = NSURL(string: baseUrl + bkgPath!)
            cell.backgroundImg.setImageWithURL(imgUrl!)
        } else {
            cell.backgroundImg.hidden = true
        }
        
        cell.titleLabel.text = title
        return cell
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        sendRequest("ref", refreshControl: refreshControl)
    }
    
    func sendRequest(type: String, refreshControl: UIRefreshControl?) {
        let apiKey = "25e59fa8eca742c2e7d6b100c5ba44da"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
         completionHandler: { (dataOrNil, response, error) in
            //check what type of request it is and how to display loading
            if(type == "hud") {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else if (type == "ref") {
                refreshControl!.endRefreshing()
            }
            //async callback
            if let data = dataOrNil {
                //Parse JSON into a NSDictionary and load it into a constant "responseDictionary"
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
            }
        })
        task.resume()
        
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }

}
