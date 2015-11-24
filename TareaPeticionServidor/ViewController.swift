//
//  ViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo on 17/11/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var txtViewResponse: UITextView!
    @IBOutlet weak var lblTituloLibro: UILabel!
    @IBOutlet weak var lblAutors: UILabel!
    @IBOutlet weak var imgPortadaLibro: UIImageView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    // Establecemos la dirección del servidor
    var urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.txtField.resignFirstResponder()
        print("Se presiono el botón de Search")
        sincrono()
        return true
    }
    
    func sincrono () {
        // El cliente ha de esperar la respuesta del servidor para poder ejecutar otra acción
        urls = urls + "\(txtField.text!)"
       
        // la convertimos en URL a través de la clase NSURL
        let url = NSURL(string: urls)

        
        do {
            // Hacemos la petición a trevés de la clase NSData (petición que va a esperar hasta recibir respuesta del servidor)
            let datos : NSData? = try NSData(contentsOfURL: url!, options: [])
            
            // MARK: Analisis del JSON
            // Como puede que lo que traiga no este en formato json, debemos hacer un do, catch
            do {
                // va a ser el resultado de los datos obtenidos los que vamos a analizar
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: .MutableLeaves)                
                
                // Voy a hacer un recorrido por el diccionario (que es todo el json), e ir filtrando entre atributos
                let objJson = json as! NSDictionary
                let diccionarioISBN = objJson["ISBN:\(self.txtField.text!)"]                
                self.lblTituloLibro.text = diccionarioISBN!["title"] as! NSString as String
                
                // Obtenemos el autor o autores
                let autores = diccionarioISBN!["authors"] as! [[String : String]]
                self.lblAutors.text = autores[0]["name"]
                
                // Obtenemos el url de la imagen de portada y se lo pasamos a el UIImage
                let covers = diccionarioISBN!["cover"] as! NSDictionary
                
                let urlImg = NSURL(string: covers["large"] as! NSString as String)
                let data = NSData(contentsOfURL: urlImg!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                self.imgPortadaLibro.image = UIImage(data: data!)
                self.imgBackground.image = UIImage(data: data!)
                
                
                
            } catch _ {
                
            }

            
            // Los datos obtenidos los codificamos a UTF8
            let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            // finalmente imprimimos en consola
            self.txtViewResponse.text = texto! as String
            self.txtViewResponse.textColor = UIColor.whiteColor()
            self.txtViewResponse.font = UIFont(name: "Trebuchet MS", size: 14.0)
        } catch {
            print("Hubo un error:")
            let alert = UIAlertController(title: "Error en la conexión", message: "Debido a un error en la comunicación no se pudo conectar, intentelo de nuevo.", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
            alert.addAction(OKAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }

        
    }
}

