//
//  ViewController.swift
//  quickNoteBook
//
//  Created by Mürşide Gökçe on 8.03.2025.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var nameArray = [String]()
    var id = [UUID]()
    var selectednote=""
    var selectedid : UUID?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButon))
        tableView.dataSource = self
        tableView.delegate = self
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newdata"),object: nil)
    }
    @objc func getData(){
        self.nameArray.removeAll(keepingCapacity: false)
        self.id.removeAll(keepingCapacity: false)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchreq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchreq.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchreq)
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID{
                    self.id.append(id)
                }
                self.tableView.reloadData()
               
            }
        }catch{
            print("error")
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "todetailsVC"{
            let destination = segue.destination as! detailsVC
            destination.chosennote = selectednote
            destination.chosenid = selectedid
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectednote = nameArray[indexPath.row]
        selectedid = id[indexPath.row]
        performSegue(withIdentifier: "todetailsVC", sender: nil)
    }
    
@objc func addButon(){
    selectednote = ""
    performSegue(withIdentifier: "todetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            
            let idString = id[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id == %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let idim = result.value(forKey: "id") as? UUID {
                            if idim == id[indexPath.row] {
                                context.delete(result)
                                
                                // Diziden veriyi sil
                                nameArray.remove(at: indexPath.row)
                                id.remove(at: indexPath.row)
                                
                                // Core Data'yı kaydet
                                do {
                                    try context.save()
                                } catch {
                                    print("Veri kaydedilirken hata oluştu: \(error)")
                                }
                                
                                // Tabloyu güncelle
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                }
            } catch {
                print("Veri silinirken hata oluştu: \(error)")
            }
        }
    }

        
    
    }
    
    



