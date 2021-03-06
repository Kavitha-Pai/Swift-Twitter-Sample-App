//
//  TimelineViewController.swift
//  JDFTwitterSample
//
//  Created by Joe Fryer on 13/07/2014.
//  Copyright (c) 2014 Joe Fryer. All rights reserved.
//

import UIKit


let TimelineViewControllerCellIdentifier = "TimelineViewControllerCellIdentifier"

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Data
    var account: Swifter?
    var tweets: [JSONValue] = []
    
    // Views
    var tableView: UITableView?
    
    // Nibs
    var tweetCellNib: UINib?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Tweets"
        
        self.setupView()
        self.tweetCellNib = UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle())
        self.tableView?.registerNib(self.tweetCellNib, forCellReuseIdentifier: TimelineViewControllerCellIdentifier)
        self.fetchTwitterHomeStreamWithMaxID(nil)
    }
    
    func setupView() {
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        self.view.addSubview(self.tableView)
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
    }
    
    func fetchTwitterHomeStreamWithMaxID(maxID: Int?) {
        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alert(error.localizedDescription)
        }
        
        self.account!.getStatusesHomeTimelineWithCount(
            20,
            sinceID: nil,
            maxID: maxID,
            trimUser: false,
            contributorDetails: false,
            includeEntities: true,
            success: {
                (statuses: [JSONValue]?) in
                
                if statuses {
                    self.tweets += statuses!
                    println("\(self.tweets[1])")
                    self.tableView?.reloadData()
                }
            },
            failure: failureHandler
        )
    }
    
    func alert(message: String) {
        var alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let numberOfTweets = self.tweets.count
        println("\(numberOfTweets)")
        return numberOfTweets
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let tweet = tweets[indexPath.row]
        let user = tweet["user"]
        var cell: TweetCell = tableView.dequeueReusableCellWithIdentifier(TimelineViewControllerCellIdentifier, forIndexPath: indexPath) as TweetCell
        cell.tweetBodyLabel.text = tweet["text"].string
        cell.fullNameLabel.text = user["name"].string
        let username = (user["screen_name"].string)
        cell.usernameLabel.text = "@\(username)"
        cell.profileImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string:user["profile_image_url"].string)), placeholderImage: UIImage(named: "TwitterAvatarPlaceholder.png"), success:{ (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            if tableView.indexPathsForVisibleRows().bridgeToObjectiveC().containsObject(indexPath) {
                cell.profileImageView.image = image;
            }
            }, failure: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.row == tweets.count - 1 {
            let tweet = tweets[indexPath.row]
            fetchTwitterHomeStreamWithMaxID(tweet["id"].integer)
        }
    }
}
