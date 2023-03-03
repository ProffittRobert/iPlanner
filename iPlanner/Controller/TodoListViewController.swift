import UIKit
import RealmSwift

class TodoListViewController: UITableViewController
{
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category?
    {
        didSet
        {
            loadItems()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    //MARK: - TableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        
        var cellContent = cell.defaultContentConfiguration()
        
        if let item = todoItems?[indexPath.row]
        {
            cellContent.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
        }
        else
        {
            cellContent.text = "No Items Added"
        }
        
        cell.contentConfiguration = cellContent
        return cell
    }
    
    //MARK: - TableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let item = todoItems[indexPath.row]
//
//        item.isDone = !item.isDone
//
//        self.saveItems()
       
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new item
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new iPlanner item.", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default)
        { (action) in
            if textField.text != ""
            {
                if let currentCategory = self.selectedCategory
                {
                    do
                    {
                        try self.realm.write
                        {
                            let newItem = Item()
                            newItem.title = textField.text!
                            currentCategory.items.append(newItem)
                        }
                    }
                    catch
                    {
                        print("Error saving new items, \(error.localizedDescription)")
                    }
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField
        { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}



