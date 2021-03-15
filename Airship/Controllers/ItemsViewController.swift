

import UIKit

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemTableCell", bundle: nil), forCellReuseIdentifier: "ItemTableCell")
        
          DataService().makeRequest { (items, error) in
            if let e = error, !e.isEmpty {
                let alert = UIAlertController(title: "Error", message: e, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let totalItems = items, totalItems.count > 0 {
                self.items = items ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableCell", for: indexPath) as? ItemTableCell else {
            fatalError("UITableViewCell must be down casted to ItemTableCell")
        }
        cell.item = items[indexPath.row]
        return cell
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.row].mediaType == .folder {
            let vc = self.storyboard?.instantiateViewController(identifier: "ItemsDetailViewController") as! ItemsDetailViewController
            vc.parentId = items[indexPath.row].itemId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
