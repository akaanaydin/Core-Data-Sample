//
//  ViewController.swift
//  Core Data Sample
//
//  Created by Arslan Kaan AYDIN on 23.04.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var sourceName = ""
    var sourceID: UUID?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        drawDesign()
        getData()
    }
    
    func drawDesign() {
        title = "Rick and Morty"
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }
    
    @objc func addItem() {
        sourceName = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }

    @objc func getData() {
        nameArray.removeAll(keepingCapacity: true)
        idArray.removeAll(keepingCapacity: true)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RickAndMortyDB")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
                tableView.reloadData()  
            }
        }catch {
            print(error)
        }
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    
}

extension ViewController {
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("NewData"), object: nil)
    }
}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.targetName = sourceName
            destinationVC.targetID = sourceID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sourceName = nameArray[indexPath.row]
        sourceID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RickAndMortyDB")
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let _ = result.value(forKey: "id") as? UUID {
                    context.delete(result)
                    nameArray.remove(at: indexPath.row)
                    idArray.remove(at: indexPath.row)
                    tableView.reloadData()
                    
                    do {
                        try context.save()
                    }catch {
                        print(error)
                    }
                }
            }
        }catch {
            print(error)
        }
    }
}
