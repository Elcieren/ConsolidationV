//
//  ViewController.swift
//  ConsolidationV
//
//  Created by Eren Elçi on 21.10.2024.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet var tableView: UITableView!
    var personArray = [Person]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView islemleri
        tableView.dataSource = self
        tableView.delegate = self
        
        //Navigation button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(imageAddClicked))
        
        
        let defaults = UserDefaults.standard
            if let savedPeople = defaults.object(forKey: "people") as? Data {
                let jsonDecoder = JSONDecoder()
                do {
                    personArray = try jsonDecoder.decode([Person].self, from: savedPeople)
                    print("Successfully loaded data.") // Debugging için ekleyebilirsin
                } catch {
                    print("Failed to load people: \(error.localizedDescription)")
                }
            }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = personArray[indexPath.row]
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = person.name
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func imageAddClicked(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage  else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.5) {
            try? jpegData.write(to: imagePath)
        }
        let person = Person(name: "Unknow", image: imageName)
        personArray.append(person)
        save()
        tableView.reloadData()
        dismiss(animated: true)
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = personArray[indexPath.row]
        
        // ad degistirme
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: UIAlertController.Style.alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Rename", style: UIAlertAction.Style.default) { [weak self , weak ac] _ in
            guard let newName = ac?.textFields?[0].text, !newName.isEmpty else { return }
                    person.name = newName // Yeni ismi güncelliyoruz
                    self?.save()
                    self?.tableView.reloadData() //
        })
        
        ac.addAction(UIAlertAction(title: "Resme git", style: .default) { [weak self] _ in
                self?.performSegue(withIdentifier: "toDetail", sender: person)
            })
        
        // silme islemi
        ac.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.personArray.remove(at: indexPath.row) // İlgili kişiyi diziden kaldır
            self?.save()
            self?.tableView.reloadData()// CollectionView'dan öğeyi sil
            })
        // cancel butonu
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        present(ac, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let detailVC = segue.destination as? DetailPageViewController {
                    if let selectedPerson = sender as? Person {
                        detailVC.selectedPerson = selectedPerson
                    }
                }
            }
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
            do {
                let saveData = try jsonEncoder.encode(personArray)
                let defaults = UserDefaults.standard
                defaults.set(saveData, forKey: "people")
                print("Successfully saved data.") // Debugging için ekleyebilirsin
            } catch {
                print("Failed to save people: \(error.localizedDescription)")
            }
    }


}

