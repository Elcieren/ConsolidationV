//
//  DetailPageViewController.swift
//  ConsolidationV
//
//  Created by Eren Elçi on 21.10.2024.
//

import UIKit

class DetailPageViewController: UIViewController {
    
    var selectedPerson: Person?

    @IBOutlet var labelName: UILabel!
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let person = selectedPerson {
            labelName.text = person.name
                    let imagePath = getDocumentsDirectory().appendingPathComponent(person.image)
                    imageView.image = UIImage(contentsOfFile: imagePath.path)
                }
        
    }
    
    func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    

   

}
