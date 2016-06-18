//
//  MoviesViewController.swift
//  RottenApples
//
//  Created by Ming Horn on 6/15/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    //Optional in case the request doesn't work or doesn't give a response
    var movies: [NSDictionary]?
    var filteredDictionary: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkError.hidden = true
        tableView.dataSource = self
        //searchBar.delegate = self
        
        //Initialize a new refresh control instance
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //Show HUD before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        sendRequest("hud", refreshControl: nil)
        
        //Deselect tableView cell
        
        
//        //Create the search controller
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.dimsBackgroundDuringPresentation = false
//        
//        searchController.searchBar.sizeToFit()
//        
//        // Sets this view controller as presenting view controller for the search interface
//        definesPresentationContext = true
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        let imgUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imgUrl!)
        
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
                    //print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
            } else {
                self.networkError.hidden = false
            }
        })
        task.resume()
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            let vc = segue.destinationViewController as? DetailsViewController
            let indexPath1 = tableView.indexPathForCell(sender as! UITableViewCell)
            let movie = movies![indexPath1!.row]
            let bannerSegue = movie.valueForKeyPath("backdrop_path") as? String
            let posterSegue = movie.valueForKeyPath("poster_path") as? String
            let titleSegue = movie.valueForKeyPath("title") as? String
            let ratingSegue = movie.valueForKeyPath("vote_average") as? Double
            let overviewSegue = movie.valueForKeyPath("overview") as? String
            
            if(bannerSegue != nil) {
                vc!.bannerLoad = bannerSegue!
            }
            if(posterSegue != nil) {
                vc!.posterLoad = posterSegue!
            }
            vc!.titleLoad = titleSegue!
            vc!.ratingLoad = ratingSegue!
            vc!.overviewLoad = overviewSegue!
        }
        
    }


}
