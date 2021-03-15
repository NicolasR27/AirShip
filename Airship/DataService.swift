
import Foundation

struct DataService {
    func makeRequest(with parent: String? = nil,  completion: @escaping ([Item]?, String?) -> Void) {
        var urlString = "https://launchpadapi.mediafly.com/2/items"
        if let p = parent {
            urlString = "\(urlString)/\(p)"
        }
        
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "productId", value: "8049e873d1bf4725bccf362395391810"),
            URLQueryItem(name: "accessToken", value: "e3464dec016648149c1c4c3ad4888d16"),
            URLQueryItem(name: "accessType", value: "view")
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                completion(nil, error?.localizedDescription)
                    return
            }

            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            if let status = responseObject?["success"] as? Bool, status == true {
                if let responseData = responseObject?["response"] as? [String: Any],
                   let items = responseData["items"] as? [[String: Any]] {
                    let parsedItems = items.map { Item($0)}
                    completion(parsedItems, nil)
                } else {
                    completion(nil, "Could not parse the data")
                }
            } else {
                completion(nil, (responseObject?["message"] as? String) ?? "")
            }
        }
        task.resume()
    }
    
    func downloadfile(urlString: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        guard let itemUrl = URL(string: urlString) else {
            completion(false, nil)
            return
        }
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: itemUrl)  { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    print("File moved to documents folder")
                    completion(true, destinationUrl)
                } catch let error {
                    print("Error Downloading File: \(error.localizedDescription)")
                    completion(false, nil)
                }
            }.resume()
        }
    }
}
