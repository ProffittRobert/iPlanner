import UIKit
import RealmSwift
import DynamicColor

class TodoListViewController: SwipeTableViewController
{
    @IBOutlet weak var searchBar: UISearchBar!
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
        
        tableView.rowHeight = 80.0
        tableView.backgroundColor = .systemCyan
    }
    
    //MARK: - TableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var cellContent = cell.defaultContentConfiguration()
        
        if let item = todoItems?[indexPath.row]
        {
            cellContent.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
            let darkenAmount = CGFloat(indexPath.row)/CGFloat(todoItems!.count)/2.0
            cell.tintColor = darkenAmount > 0.2 ? .white : .black
            cellContent.textProperties.color = darkenAmount > 0.2 ? .white : .black
            cell.backgroundColor = UIColor(hexString: selectedCategory!.color).darkened(amount: darkenAmount)
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
        if let item = todoItems?[indexPath.row]
        {
            do
            {
                try realm.write
                {
                    item.isDone = !item.isDone
                }
            }
            catch
            {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()

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
                            newItem.dateCreated = Date()
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
    
    //MARK: - Delete Date from Swipe
    override func updateModel(at indexPath: IndexPath)
    {
        if let itemForDeletion = self.todoItems?[indexPath.row]
            {
              do
              {
                  try self.realm.write
                  {
                      self.realm.delete(itemForDeletion)
                  }
              }
              catch
              {
                  print("Error deleting item, \(error)")
              }
            }
    }
}

//MARK: - Search Bar Methods
extension TodoListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: K.keyPath, ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.count == 0
        {
            loadItems()
            DispatchQueue.main.async
            {
                searchBar.resignFirstResponder()
            }
        }
    }
}



