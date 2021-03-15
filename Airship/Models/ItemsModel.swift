
import Foundation

enum MediaType {
    case folder
    case image
    case video
    case document
}

struct Item {
    let itemId : String
    let parentId : String
    var title: String
    var thumbnail : String
    var asset: String
    var mediaType: MediaType
    
    init(_ json: [String: Any]) {
        itemId = json["id"] as? String ?? ""
        parentId = json["parentId"] as? String ?? ""
        mediaType = .folder
        asset = ""
        thumbnail = ""
        title = ""
        
        if let thumb = json["thumbnail"] as? [String: Any] {
            thumbnail = thumb["url"] as? String ?? ""
            asset = thumbnail
        }
        
        if let media = json["asset"] as? [String: Any] {
            title = media["filename"] as? String ?? ""
            asset = media["url"] as? String ?? ""
            let type = media["type"] as? String ?? ""
            if type == "image" {
                mediaType = .image
            } else if type == "document" {
                mediaType = .document
            } else {
                mediaType = .video
            }
        } else {
            if let folderTitle = json["metadata"] as? [String: Any] {
                title = folderTitle["title"] as? String ?? ""
            }
        }
        
    }
}




