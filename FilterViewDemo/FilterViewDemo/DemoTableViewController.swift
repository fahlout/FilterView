//
//  DemoTableViewController.swift
//  FilterViewDemo
//
//  Created by Niklas Fahl on 1/18/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

import UIKit

class TestObject: NSObject {
    var name: String = ""
    var job: String = ""
    var age: Int = 0
}

class DemoTableViewController: UITableViewController {
    
    let testNames = ["Dietrich", "Hans", "Helmut", "Manni", "Arnold", "William"]
    let testJobs = ["Music", "Cars", "Landscaping", "Restaurants", "Books", "Clubs & Bars"]
    let testAges = [60, 54, 13, 7, 99, 28]
    
    var testObjects: [TestObject] = []
    var filteredObjects: [TestObject] = []
    
    var filterView: NFFilterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "FilterView Demo"
        
        // Add button to open filter view with
        let filterButton = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.Plain, target: self, action: "openNFFilterController")
        self.navigationItem.rightBarButtonItem = filterButton
        
        generateRandomArray()
        filteredObjects = testObjects
        addObserverForFilterUpdates()
        
        // Initialize NFFilterController
        filterView = NFFilterView(objects: testObjects, properties: ["name", "job", "age"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addObserverForFilterUpdates() {
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "filteredObjectsDidUpdate:", name: "filteredObjectsDidUpdate", object: nil)
    }
    
    func generateRandomArray() {
        // Test input
        for var i = 0; i < 12; i++ {
            let nameIndex = Int(arc4random_uniform(5) + 1)
            let jobIndex = Int(arc4random_uniform(5) + 1)
            let ageIndex = Int(arc4random_uniform(5) + 1)
            
            let newObject = TestObject()
            newObject.name = testNames[nameIndex]
            newObject.job = testJobs[jobIndex]
            newObject.age = testAges[ageIndex]
            testObjects.append(newObject)
        }
    }
    
    func openNFFilterController() {
        // Show NFFilterController
        filterView!.show(self.navigationController!)
    }
    
    // MARK: - Handle update notification
    
    func filteredObjectsDidUpdate(notification: NSNotification) {
        filteredObjects = notification.userInfo!["filteredObjects"] as! [TestObject]
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        // Configure the cell...
        let testObject = filteredObjects[indexPath.row]
        cell.textLabel?.text = "\(testObject.name) | \(testObject.job) | \(testObject.age)"

        return cell
    }
}
