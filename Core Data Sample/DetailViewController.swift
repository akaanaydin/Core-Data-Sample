//
//  DetailViewController.swift
//  Core Data Sample
//
//  Created by Arslan Kaan AYDIN on 23.04.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var raceTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    var targetName = ""
    var targetID: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        drawDesign()
        targetTransfer()
    }
    
    func drawDesign() {
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func targetTransfer() {
        if targetName != "" {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RickAndMortyDB")
            let idString = targetID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameTextField.text = name
                    }
                    if let race = result.value(forKey: "race") as? String {
                        raceTextField.text = race
                    }
                    if let age = result.value(forKey: "age") as? Int {
                        ageTextField.text = String(age)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                }
            }catch {
                print(error)
            }
        }else {
            
        }
    }
    
    @objc func imageTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "RickAndMortyDB", into: context)
        
        let imagePress = imageView.image?.jpegData(compressionQuality: 0.5)
        
        saveData.setValue(imagePress, forKey: "image")
        saveData.setValue(UUID(), forKey: "id")
        saveData.setValue(nameTextField.text!, forKey: "name")
        saveData.setValue(raceTextField.text!, forKey: "race")
        if let age = Int(ageTextField.text!) {
            saveData.setValue(age, forKey: "age")
        }
        
        do {
            try context.save()
            print("Success")
        }catch {
            print(error)
        }
        
        NotificationCenter.default.post(name: .init(rawValue: "NewData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
