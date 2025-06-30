
import UIKit
import CoreData

class CoffeeShopsViewController: UITableViewController {
    
    // NSFetchedResultsController для управления выборкой и обновлением таблицы
    var fetchedResultsController: NSFetchedResultsController<CoffeeShop>!
   
    // Свойство контроллера поиска
    let searchController = UISearchController(searchResultsController: nil)
    
    // свойство для отфильтрованных данных
    var filteredCoffeeShops: [CoffeeShop] = []
    var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Coffeman"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Инициализируем fetchedResultsController
        initializeFetchedResultsController()
        
        // Кнопка "+" для добавления новой кофейни
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoffeeShop))
        
        tableView.register(CoffeeShopTableViewCell.self, forCellReuseIdentifier: "CoffeeShopCell") // регистрация ячейки
        tableView.rowHeight = 75

    
        // Настройка searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск кофеен"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
      
   
    }
 
   
    
    
    
    // Инициализация NSFetchedResultsController с сортировкой по дате добавления
    func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CoffeeShop> = CoffeeShop.fetchRequest()
        
        // Правильное имя ключа
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: PersistenceManager.shared.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка загрузки кофеен: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Переход на экран добавления/редактирования кофейни
    
    func showAddEditCoffeeShop(coffeeShop: CoffeeShop? = nil) {
        let addVC = AddCoffeeShopViewController(style: .grouped)
        addVC.coffeeShopToEdit = coffeeShop // передаем объект для редактирования (nil - для нового)
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    
    // Вызов при нажатии на кнопку "+" для добавления новой кофейни
    
    @objc func addCoffeeShop() {
        let addVC = AddCoffeeShopViewController(style: .grouped)
        // Оборачиваем в навигационный контроллер, чтобы появилась навигационная панель с кнопкой Cancel
        let navController = UINavigationController(rootViewController: addVC)
        present(navController, animated: true)
    }
    
    
    // Вызов при выборе кофейни из списка для редактирования
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coffeeShop: CoffeeShop
        if isFiltering {
            coffeeShop = filteredCoffeeShops[indexPath.row]
        } else {
            coffeeShop = fetchedResultsController.object(at: indexPath)
        }
        
        let editVC = AddCoffeeShopViewController(style: .grouped)
        editVC.coffeeShopToEdit = coffeeShop
        navigationController?.pushViewController(editVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // удаление кофейни по свайпу
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let coffeeShopToDelete = fetchedResultsController.object(at: indexPath)
            
            // получаем контекст Core Data
            let context = PersistenceManager.shared.context
            
        // удаляем объект из контекста
            
            context.delete(coffeeShopToDelete)
            
            do {
                // сохраняем изменения в Core Data
                try context.save()
            } catch {
                print("Ошибка при удалении кофейни: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
        if isFiltering {
            return filteredCoffeeShops.count
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }
    
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Используем кастомную ячейку
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeShopCell", for: indexPath) as! CoffeeShopTableViewCell
        let coffeeShop: CoffeeShop
        if isFiltering {
            coffeeShop = filteredCoffeeShops[indexPath.row]
        } else {
            coffeeShop = fetchedResultsController.object(at: indexPath)
        }
        cell.configure(with: coffeeShop)
        return cell
    }
}


// MARK: - NSFetchedResultsControllerDelegate - для автоматического обновления таблицы

extension CoffeeShopsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            break
        }
    }

}


// расширение для UISearchResultsUpdating

extension CoffeeShopsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    func filterContentForSearchText(_ searchText: String) {
        guard let allCoffeeShops = fetchedResultsController.fetchedObjects else { return }
        
        filteredCoffeeShops = allCoffeeShops.filter { coffeeShop in
            let nameMatch = coffeeShop.name?.range(of: searchText, options: .caseInsensitive) != nil
            let typeMatch = coffeeShop.type?.range(of: searchText, options: .caseInsensitive) != nil
            let addressMatch = coffeeShop.address?.range(of: searchText, options: .caseInsensitive) != nil
            return nameMatch || typeMatch || addressMatch
        }
        tableView.reloadData()
    }
}
