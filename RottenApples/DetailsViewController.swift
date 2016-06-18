//
//  DetailsViewController.swift
//  RottenApples
//
//  Created by Ming Horn on 6/17/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var posterLoad = ""
    var bannerLoad = ""
    var titleLoad = ""
    var ratingLoad = 0.0
    var overviewLoad = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let baseURL = "https://image.tmdb.org/t/p/w342"
        bannerImage.setImageWithURL(NSURL(string: baseURL + bannerLoad)!)
        posterImage.setImageWithURL(NSURL(string: baseURL + posterLoad)!)
        titleLabel.text = titleLoad
        ratingLabel.text = String("Rating: \(ratingLoad)")
        overviewLabel.text = overviewLoad
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
