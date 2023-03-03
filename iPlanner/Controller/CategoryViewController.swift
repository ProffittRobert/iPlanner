//
//  CategoryViewController.swift
//  iPlanner
//
//  Created by Robert Proffitt on 3/2/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController
{
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        var cellContent = cell.defaultContentConfiguration()
        
        if let category = categories?[indexPath.row]
        {
            cellContent.text = category.name
        }
        else
        {
            cellContent.text = "No Categories Added Yet"
        }
        
        cell.contentConfiguration = cellContent
        return cell
    }
    
    //MARK: - data manipulation methods
    
    func save(_ category: Category)
    {
        do
        {
            try realm.write
            {
                realm.add(category)
            }
        }
        catch
        {
            print("Error saving category, \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories()
    {
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category.", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default)
        { (action) in
            if textField.text != ""
            {
                let newCategory = Category()
                newCategory.name = textField.text!
                
                self.save(newCategory)
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField
        { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow
        {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
