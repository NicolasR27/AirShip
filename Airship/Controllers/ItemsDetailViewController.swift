import UIKit
import QuickLook


class ItemsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDataSource {
    @IBOutlet weak var tableView: UITableView!
    var parentId: String = ""
    var items: [Item] = []
    var previewURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemTableCell", bundle: nil), forCellReuseIdentifier: "ItemTableCell")
        
        DataService().makeRequest(with: parentId) { (items, error) in
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
    
    func attachPreviewController(_ index: Int) {
        DataService().downloadfile(urlString: items[index].asset) { (success, locationURL) in
            if success {
                self.previewURL = locationURL!
                
                DispatchQueue.main.async {
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    self.present(previewController, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "File is not ready for preview", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
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
        attachPreviewController(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - QLPreviewController data source
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController,previewItemAt index: Int) -> QLPreviewItem {
        return previewURL! as QLPreviewItem
    }
}
