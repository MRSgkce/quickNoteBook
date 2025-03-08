//
//  detailsVC.swift
//  quickNoteBook
//
//  Created by Mürşide Gökçe on 8.03.2025.
//
import Foundation
import UIKit
import CoreData

class detailsVC : UIViewController,UIImagePickerControllerDelegate
,UINavigationControllerDelegate {
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var artist: UITextField!
    @IBOutlet weak var image: UIImageView!

    
    var chosennote = ""
    var chosenid : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosennote != "" {
            
         
            //core data ile çekme id'ye göre filtreleme
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            
            let idString = chosenid?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{ //dizi geldiği için fora soktuk
                        if let names = result.value(forKey: "name") as? String{
                            name.text = names
                        }
                        if let artists = result.value(forKey: "artist") as? String{
                            artist.text = artists
                        }
                        if let yearm = result.value(forKey: "year") as? Int{
                            year.text = String(yearm)
                        }
                        if let imagedata = result.value(forKey: "image") as? Data{
                            let imagem = UIImage(data : imagedata)
                            image.image = imagem
                        }
                        
                    }
                    
                }
            }catch {
                
            }
            
        } else{
            name.text = ""
            year.text = ""
            artist.text = ""
        }
        //recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideEdit))
        view.addGestureRecognizer(gestureRecognizer)
        
        image.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageRecognizer))
        image.addGestureRecognizer(imageRecognizer)
    }
    
    //objc selector
    @objc func imageRecognizer(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    @objc func hideEdit(){
        view.endEditing(true)
    }
    @IBAction func kaydetButon(_ sender: Any) {
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let notes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        notes.setValue(name.text!, forKey: "name")
        
        notes.setValue(artist.text!, forKey: "artist")
        
        if let year = Int(year.text!){
            notes.setValue(year, forKey: "year")
        }
        
        notes.setValue(UUID(), forKey: "id")
        
        let data = image.image!.jpegData(compressionQuality: 0.5)
        notes.setValue(data, forKey: "image")
        
        do{
            try  context.save()
            print("başarılı")
            NotificationCenter.default.post(name: NSNotification.Name("newdata"), object: nil)
            self.navigationController?.popViewController(animated: true)
            
        } catch{
                print("error")
            }
        }
    }

