//
//  CategoryViewController.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import UIKit
import ChameleonFramework
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>!
    
    @IBOutlet weak var ListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.flatPowderBlue()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.tintColor = UIColor.flatWhite()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1 // if categories is not nil, return it's count, otherwise return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(ListTableView, cellForRowAt: indexPath)
    
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet."
        
        cell.backgroundColor = UIColor.flatPowderBlue().darken(byPercentage:
        
            CGFloat(indexPath.row) / CGFloat(categories.count)
            
        )
        cell.textLabel?.textColor = UIColor.flatWhite()
        cell.textLabel?.font = UIFont.init(name: "Euphemia UCAS", size: CGFloat(21.0))
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToItems" {
            
            let destinationVC = segue.destination as! ItemsViewController
            
            if let indexPath = ListTableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
                
            }
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        ListTableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        ListTableView.reloadData()
    }
    
    //MARK: - Deleting Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    
    }
    
    //MARK: - Adding New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
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
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {

        self.dismiss(animated: true, completion: nil)
    }
    
}


