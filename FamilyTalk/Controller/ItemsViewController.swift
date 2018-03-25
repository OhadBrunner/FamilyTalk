//
//  ItemsViewController.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import UIKit
import RealmSwift

class ItemsViewController: SwipeTableViewController {

    var items: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = selectedCategory?.name
    }

    override func viewWillAppear(_ animated: Bool) {
//
//        if let colourHex = selectedCategory?.colour {
//
//            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
//
//            navBar.barTintColor = UIColor(hexString: colourHex)
//        }
        navigationController?.navigationBar.barTintColor = UIColor.flatPowderBlue()
        searchBar.barTintColor = UIColor.flatPowderBlue()
        
        //navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.flatWhite()]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //guard let originalColour = UIColor(hexString: "")
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            cell.backgroundColor = UIColor.flatPowderBlue().darken(byPercentage:
                
                CGFloat(indexPath.row) / CGFloat((items?.count)!)
                
            )
            
            cell.textLabel?.textColor = UIColor.flatWhite()
            cell.textLabel?.font = UIFont.init(name: "Euphemia UCAS", size: CGFloat(21.0))
            cell.accessoryType = item.done == true ? .checkmark : .none // shortened
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
            try realm.write {
                item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        //this handler completion gets triggred once the alert controller pops up so we can't use the alertTextField parameter outside this scope later on when we need to get what the user entered. hence, we using another parameter outside this scope - textField.
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
      
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
          
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    

    override func updateModel(at indexPath: IndexPath) {

        if let item = items?[indexPath.row] {
            do {
             try realm.write {
                realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}
    
    //MARK: - Search bar methods
    
    extension ItemsViewController: UISearchBarDelegate {
        
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            
            tableView.reloadData()
            
        }
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
            if searchBar.text?.count == 0 {
                loadItems()
                
                DispatchQueue.main.async {
                    
                    searchBar.resignFirstResponder()
                }
            }
        }
    }




