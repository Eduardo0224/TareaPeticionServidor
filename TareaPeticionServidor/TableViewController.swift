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
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("peticionLibros")
        
        do {
            let librosEntidad = try self.contexto?.executeFetchRequest(peticion!)
            
            for libro in librosEntidad! {
                let tituloEntidad = libro.valueForKey("titulo") as! String
                let autorEntidad = libro.valueForKey("autor") as! String
                
                let bSVC = BookSearchViewController()
                let portadaEntidad = bSVC.imageWithBorderFromImage(UIImage(data: libro.valueForKey("portada") as! NSData)!)
                
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
        

        // Cambiar el color de la barra de estado
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.navigationController!.navigationBar.barStyle = .BlackTranslucent;
        self.navigationController!.navigationBar.translucent = true;
        self.navigationItem.title = "Libros"
        



    }
    
    override func viewDidAppear(animated: Bool) {
        

        
        if let imagenTabla = imagenTable {
            self.tableView.backgroundView = UIImageView(image: imagenTabla)
        }
        else {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "Imagen2.jpg"))
        }
        

        
        self.tableView!.reloadData()
        
        tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.backgroundView!.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.tableView.backgroundView!.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.tableView.backgroundView!.addSubview(blurEffectView)
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueBookSearch" {
            let bookSearch = segue.destinationViewController as? BookSearchViewController
            bookSearch!.delegate = self
            bookSearch!.delegateNuevoDelegado = self
        }
        
        if segue.identifier == "segueDetail" {
            
            print("Encontro el identifier del segue")
            if let destination = segue.destinationViewController as? DetailViewController {
                            print("El viewcontroller de destino se castea a DeatilViewController")
                
                    
                    
                    print("El sender es un UITableViewCell")
                    
                
                    print("El indexPath es \(index)")
                    
                    let tituloD = self.titulos[index!]
                    destination.tituloDetalle = tituloD
                    
                    let autoresD = self.autores[index!]
                    destination.autoresDetalle = autoresD
                    
                    let portadaD = self.portadas[index!]
                    destination.portadaDetalle = portadaD
                
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("Cantidad de elementos en el arreglo de titulos \(self.titulos.count)")
        return self.titulos.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier("Celda")!
        cell = UITableViewCell(style: .Default, reuseIdentifier: "Celda")
        
        // Configure the cell...
        cell.textLabel?.text = self.titulos[indexPath.row]
        cell.textLabel?.shadowColor = UIColor.blackColor()
        cell.textLabel?.shadowOffset = CGSize(width: 0, height: 1)
        
        if(indexPath.row % 2 == 1){
            cell.backgroundColor = UIColor.clearColor()
        }else{
            cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        }
        
        let color = UIColor(red: 180 / 255, green: 138 / 255, blue: 171 / 255, alpha: 1)
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = color
        cell.selectedBackgroundView = myCustomSelectionColorView

        cell.textLabel?.textColor = UIColor.whiteColor()

        cell.separatorInset = UIEdgeInsetsZero
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let _ = tableView.cellForRowAtIndexPath(indexPath) {
            print(self.titulos[indexPath.row])
            index = indexPath.row
            performSegueWithIdentifier("segueDetail", sender: self)
        }
        else {
        }

    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
