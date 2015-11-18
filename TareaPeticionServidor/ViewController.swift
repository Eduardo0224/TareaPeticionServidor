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

