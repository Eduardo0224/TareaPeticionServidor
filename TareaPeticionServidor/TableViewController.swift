//
//  TableViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo on 7/12/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit
import CoreData

extension TableViewController: BookSearchDelegate {
    func updateData(data: Model) {
        self.modelo = data
        
    }
}

extension TableViewController : NuevoDelegado {
    func mandarTitulo(tituloMandado: String, imagenMandada: UIImage, _autorMandado : String) {
        self.titulos.append(tituloMandado)
        self.autores.append(_autorMandado)
        self.portadas.append(imagenMandada)
        
        self.imagenTable = imagenMandada
    }
}


class TableViewController: UITableViewController {
    
    // nos permite acceder al contexto de la pila de core data
    var contexto : NSManagedObjectContext? = nil
    
    
    
    var titulos : [String] = []
    var autores : [String] = []
    var portadas : [UIImage] = []
    var index: Int?
    
    
    var modelo : Model = Model(_titulo: [])
    
    var imagenTable : UIImage? = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contexto = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entity(forEntityName: "Libro", in: self.contexto!)
        
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplate(forName: "peticionLibros")
        
        do {
            let librosEntidad = try self.contexto?.fetch(peticion!) as! [NSManagedObject]
            
            for libro in librosEntidad {
                let tituloEntidad = libro.value(forKey: "titulo") as! String
                let autorEntidad = libro.value(forKey: "autor") as! String
                
                let bSVC = BookSearchViewController()
                let portadaEntidad = bSVC.imageWithBorderFromImage(source: UIImage(data: libro.value(forKey: "portada") as! Data)!)               
                
                self.titulos.append(tituloEntidad)
                self.autores.append(autorEntidad)
                self.portadas.append(portadaEntidad)
            }
        }
        catch {
            
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.navigationController!.navigationBar.barStyle = .blackTranslucent;
        self.navigationController!.navigationBar.isTranslucent = true;
        self.navigationItem.title = "Libros"
    }
    
     // Cambiar el color de la barra de estado
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        

        
        if let imagenTabla = imagenTable {
            self.tableView.backgroundView = UIImageView(image: imagenTabla)
        }
        else {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "Imagen2.jpg"))
        }
        

        
        self.tableView!.reloadData()
        
        tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundView!.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.tableView.backgroundView!.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.tableView.backgroundView!.addSubview(blurEffectView)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBookSearch" {
            let bookSearch = segue.destination as? BookSearchViewController
            bookSearch!.delegate = self
            bookSearch!.delegateNuevoDelegado = self
        }
        
        if segue.identifier == "segueDetail" {
            
            print("Encontro el identifier del segue")
            if let destination = segue.destination as? DetailViewController {
                print("El viewcontroller de destino se castea a DeatilViewController")
                
                
                
                print("El sender es un UITableViewCell")
                
                
                print("El indexPath es \(String(describing: index))")
                
                let tituloD = self.titulos[index!]
                destination.tituloDetalle = tituloD
                
                let autoresD = self.autores[index!]
                destination.autoresDetalle = autoresD
                
                let portadaD = self.portadas[index!]
                destination.portadaDetalle = portadaD
                
            }
        }
    }    
}

extension TableViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("Cantidad de elementos en el arreglo de titulos \(self.titulos.count)")
        return self.titulos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Celda")!
        cell = UITableViewCell(style: .default, reuseIdentifier: "Celda")
        
        // Configure the cell...
        cell.textLabel?.text = self.titulos[indexPath.row]
        cell.textLabel?.shadowColor = UIColor.black
        cell.textLabel?.shadowOffset = CGSize(width: 0, height: 1)
        
        if(indexPath.row % 2 == 1){
            cell.backgroundColor = UIColor.clear
        }else{
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        
        let color = UIColor(red: 180 / 255, green: 138 / 255, blue: 171 / 255, alpha: 1)
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = color
        cell.selectedBackgroundView = myCustomSelectionColorView
        
        cell.textLabel?.textColor = UIColor.white
        
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            print(self.titulos[indexPath.row])
            index = indexPath.row
            performSegue(withIdentifier: "segueDetail", sender: self)
        }
    }
}
