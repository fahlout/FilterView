//
//  NFFilterView.swift
//
//  Created by Niklas Fahl on 1/15/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

import UIKit

class NFFilterView: UITableViewController {

    var filterObjects: [AnyObject] = []
    var filteredObjects: [AnyObject] = []
    
    var filterProperties: [String] = []
    
    // Dictionaries holding data to make selection and displaying possible
    // Key: sectionIndex+propertyName+filterByName
    // Value: (filterByName, amountOfObjects)
    var selectedFilters: [String: (String, Int)] = [:]
    var filters: [String: (String, Int)] = [:]
    
    required init(objects: [AnyObject], properties: [String]) {
        super.init(style: .Grouped)
        
        filterObjects = objects
        filterProperties = properties
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        // Generate defaults
        generateDefaultSelections()
        generateFilters(filterObjects)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI Setup
    func configure() {
        self.title = "Filter"
        
        addBarButtons()
        configureTableView()
    }
    
    // Table View
    func configureTableView() {
        tableView.registerClass(NFFilterViewTableViewCell.self, forCellReuseIdentifier: "NFFilterViewTableViewCell")
    }
    
    // Bar buttons
    func addBarButtons() {
        addResetBarButton()
        addDoneBarButton()
    }
    
    func addDoneBarButton() {
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "closeFilterController")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func addResetBarButton() {
        let resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Plain, target: self, action: "resetFilters")
        self.navigationItem.leftBarButtonItem = resetButton
    }
    
    // MARK: - Close/Reset Filter Controller
    
    func closeFilterController() {
        // Remember selection
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resetFilters() {
        selectedFilters = [:]
        generateDefaultSelections()
        generateFilters(filterObjects)
        tableView.reloadData()
    }
    
    // MARK: - Show Filter Controller
    func show(presentingViewController: UIViewController) {
        let navigationController: UINavigationController = UINavigationController(rootViewController: self)
        presentingViewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Generate selections
    func generateDefaultSelections() {
        var sectionIndex = 0
        for propertyName in filterProperties {
            let filterKey = "1+\(sectionIndex)+\(propertyName)+All"
            selectedFilters[filterKey] = ("All", filterObjects.count)
            
            sectionIndex++
        }
    }
    
    // MARK: - Generate Filters
    func generateFilters(objects: [AnyObject]) {
        filters = [:]
        
        var sectionIndex = 0
        
        for object in objects {
            for propertyName in filterProperties {
                let filterByName = convertToString(object.valueForKey(propertyName))
                
                if filterByName != "" {
                    let filterKey = "2+\(sectionIndex)+\(propertyName)+\(filterByName)"
                    if filters[filterKey] == nil {
                        filters[filterKey] = (filterByName, 1)
                    } else {
                        filters[filterKey] = (filterByName, filters[filterKey]!.1 + 1)
                    }
                }
                
                sectionIndex++
            }
            
            sectionIndex = 0
        }
        
        for propertyName in filterProperties {
            let filterKey = "1+\(sectionIndex)+\(propertyName)+All"
            
            // Calculate "All" count
            let propertyNameInSection = filterProperties[sectionIndex]
            let allKeys = Array(filters.keys).sort()
            let keys = allKeys.filter() { $0.rangeOfString(propertyNameInSection) != nil }
            var allAmount = 0
            for key in keys {
                allAmount += filters[key]!.1
            }
            
            filters[filterKey] = ("All", allAmount)
            
            sectionIndex++
        }
    }
    
    // MARK: - Test filtering with predicate
    func filterBySelections() {
        filteredObjects = filterObjects.map() { $0 }
        for selectionKey in selectedFilters.keys {
            let selectionParts = selectionKey.componentsSeparatedByString("+")
            let selectionFilterByName = selectionParts[3]
            if selectionFilterByName != "All" {
                let selectionProperty = selectionParts[2]
                filteredObjects = filterObjects.filter() { convertToString($0.valueForKey(selectionProperty)) == selectionFilterByName}
            }
        }
    }
    
    func convertToString(value: AnyObject?) -> String {
        if value == nil {
            return ""
        } else {
            return "\(value!)"
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filterProperties.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let propertyNameInSection = filterProperties[section]
        let keys = Array(filters.keys)
        let propertyInSectionCount = (keys.filter() { $0.rangeOfString(propertyNameInSection) != nil }).count
        return propertyInSectionCount
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NFFilterViewTableViewCell", forIndexPath: indexPath) as! NFFilterViewTableViewCell

        // Get values to configure cell
        let propertyNameInSection = filterProperties[indexPath.section]
        let allKeys = Array(filters.keys).sort()
        let keys = allKeys.filter() { $0.rangeOfString(propertyNameInSection) != nil }
        
        cell.filterKey = keys[indexPath.row]
        cell.filterValue = filters[cell.filterKey]!.0
        cell.textLabel?.text = cell.filterValue + " (\(filters[cell.filterKey]!.1))"
        
        if selectedFilters[cell.filterKey] != nil {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: NFFilterViewTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! NFFilterViewTableViewCell
        
        // Make sure user cannot deselect "All" only select it when it's appropriate
        if indexPath.row > 0 {
            let filterByName = cell.filterValue
            let propertyName = filterProperties[indexPath.section]
            
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                let allKey = "1+\(indexPath.section)+\(filterProperties[indexPath.section])+All"
                selectedFilters.removeValueForKey(allKey)
                selectedFilters[cell.filterKey] = filters[cell.filterKey]
                
                // Filter by new selection
                filteredObjects = filterObjects.filter() { convertToString($0.valueForKey(propertyName)) == filterByName}
            } else {
                cell.accessoryType = .None
                selectedFilters.removeValueForKey(cell.filterKey)
                
                // Filter by current selections after deselection
                filterBySelections()
            }
            
            // Generate filters with new selections
            generateFilters(filteredObjects)
            tableView.reloadData()
        } else {
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                let allKey = "1+\(indexPath.section)+\(filterProperties[indexPath.section])+All"
                selectedFilters.removeValueForKey(allKey)
                selectedFilters[cell.filterKey] = filters[cell.filterKey]
                
                let allKeys = Array(selectedFilters.keys).sort()
                let filterString = "2+\(indexPath.section)+\(filterProperties[indexPath.section])"
                let keys = allKeys.filter() { $0.rangeOfString(filterString) != nil }
                for key in keys {
                    selectedFilters.removeValueForKey(key)
                }
                
                filterBySelections()
                generateFilters(filteredObjects)
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filterProperties[section]
    }
}
