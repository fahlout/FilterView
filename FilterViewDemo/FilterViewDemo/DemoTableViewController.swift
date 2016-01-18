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
    var category: String = ""
    var count: Int = 0
}

class DemoTableViewController: UITableViewController {
    
    let testNames = ["Dietrich", "Hans", "Helmut", "Manni", "Arnold", "William"]
    let testCategories = ["Music", "Cars", "Landscaping", "Restaurants", "Books", "Clubs & Bars"]
    let testCounts = [60, 54, 13, 7, 99, 28]
    var testObjects: [TestObject] = []
    var filteredObjects: [TestObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "FilterView Demo"
        
        // Add button to open filter view with
        let filterButton = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.Plain, target: self, action: "openNFFilterController")
        self.navigationItem.rightBarButtonItem = filterButton
        
        generateRandomArray()
        filteredObjects = testObjects
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateRandomArray() {
        // Test input
        for var i = 0; i < 12; i++ {
            let nameIndex = Int(arc4random_uniform(5) + 1)
            let categoryIndex = Int(arc4random_uniform(5) + 1)
            let countIndex = Int(arc4random_uniform(5) + 1)
            
            let newObject = TestObject()
            newObject.name = testNames[nameIndex]
            newObject.category = testCategories[categoryIndex]
            newObject.count = testCounts[countIndex]
            testObjects.append(newObject)
        }
    }
    
    func openNFFilterController() {
        // Initialize NFFilterController
        let filterController = NFFilterView(objects: testObjects, properties: ["name", "category", "count"])
        
        // Show NFFilterController
        filterController.show(self.navigationController!)
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
        cell.textLabel?.text = "\(testObject.name) | \(testObject.category) | \(testObject.count)"

        return cell
    }
}
