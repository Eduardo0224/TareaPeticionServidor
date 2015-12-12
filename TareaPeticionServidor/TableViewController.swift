//
//  TableViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo on 7/12/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit

extension TableViewController: BookSearchDelegate {
    func updateData(data: Model) {
        self.modelo = data
        print("El modelo regresado es: \(self.modelo)")
        
    }
}

extension TableViewController : NuevoDelegado {
    func mandarTitulo(tituloMandado: String, imagenMandada: UIImage) {
        self.titulos.append(tituloMandado)
        self.imagenTable = imagenMandada
    }
}


class TableViewController: UITableViewController {
    
    var titulos : [String] = []
    
    
    var modelo : Model = Model(_titulo: [])
    
    var imagenTable : UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        

        // Cambiar el color de la barra de estado
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.navigationController!.navigationBar.barStyle = .BlackTranslucent;
        self.navigationController!.navigationBar.translucent = true;
        self.navigationItem.title = "Libros"

        print("LA primer vez vacio: \(self.modelo.titulo)")


    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Imagen2.jpg"))
        self.tableView!.reloadData()
        self.tableView.backgroundView = UIImageView(image: self.imagenTable)
        self.tableView.backgroundView!.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.tableView.backgroundView!.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.tableView.backgroundView!.addSubview(blurEffectView)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueBookSearch" {
            let bookTales = segue.destinationViewController as? BookSearchViewController
            bookTales!.delegate = self
            bookTales!.delegateNuevoDelegado = self
            
            

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
//        return self.modelo.titulo.count
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

        cell.textLabel?.textColor = UIColor.whiteColor()

        

        return cell
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
