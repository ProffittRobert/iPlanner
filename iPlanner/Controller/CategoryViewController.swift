import UIKit
import RealmSwift
import DynamicColor

class CategoryViewController: SwipeTableViewController
{
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 80.0
        tableView.backgroundColor = .systemCyan
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let currentCategory = categories?[indexPath.row]
        {
            var cellContent = cell.defaultContentConfiguration()
            cellContent.text = currentCategory.name
            cell.contentConfiguration = cellContent
            cell.backgroundColor = DynamicColor(hexString: currentCategory.color)
        }
        
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
    
    //MARK: - Delete Date from Swipe
    override func updateModel(at indexPath: IndexPath)
    {
        if let categoryForDeletion = self.categories?[indexPath.row]
            {
              do
              {
                  try self.realm.write
                  {
                      self.realm.delete(categoryForDeletion)
                  }
              }
              catch
              {
                  print("Error deleting category, \(error)")
              }
            }
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
                let colorString = DynamicColor.random.toHexString()
                newCategory.color = colorString
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
        performSegue(withIdentifier: K.segueIdentifier, sender: self)
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

extension UIColor
{
    static var random: UIColor
    {
        return UIColor(
            red: .random(in: 0.3...1),
            green: .random(in: 0.3...1),
            blue: .random(in: 0.3...1),
            alpha: 1.0
        )
    }
}

