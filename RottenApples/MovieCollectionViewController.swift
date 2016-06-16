//
//  MovieCollectionViewController.swift
//  RottenApples
//
//  Created by Ming Horn on 6/15/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieCollectionViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var moviesCollection: UICollectionView!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moviesCollection.dataSource = self
        
        //Initialize a new refresh control instance
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        moviesCollection.insertSubview(refreshControl, atIndex: 0)
        
        //Show HUD before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        sendRequest("hud", refreshControl: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    self.moviesCollection.reloadData()
                }
            }
        })
        task.resume()
        
   }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = moviesCollection.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell

        let movie = movies![indexPath.row]
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        let imgUrl = NSURL(string: baseUrl + posterPath)
        cell.MoviePoster.setImageWithURL(imgUrl!)

        return cell
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        sendRequest("ref", refreshControl: refreshControl)
    }

}


