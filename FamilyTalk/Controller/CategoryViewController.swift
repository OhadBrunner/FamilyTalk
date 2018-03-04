//
//  CategoryViewController.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import UIKit
import CoreData

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var ListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ListTableView.dataSource = self
        ListTableView.delegate = self
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToItems" {
            
            let destinationVC = segue.destination as! ItemsViewController
            
            if let indexPath = ListTableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories[indexPath.row]
                
            }
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategory() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        ListTableView.reloadData()
    }
    
    func loadCategories() {
        
        //this is the request we are going to send in order to retrieve our data from the data base
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        ListTableView.reloadData()
    }
    
    //MARK: - Add New Categories
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context) // אפשר לאתחל כמו שאני מאתחל הודעה? וזה ישר שולח לדאטאבייס? או הפוך
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategory()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Add a new category"
            
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func FamilyTalkPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    
}

