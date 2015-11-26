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
    
    var urlImg : NSURL?
    
    // Establecemos la dirección del servidor
    var urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtField.delegate = self
        
        // MARK: Efecto Blur
        imgBackground.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = imgBackground.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        imgBackground.addSubview(blurEffectView)
    }
    
    func imageWithBorderFromImage(source: UIImage) -> UIImage {
        let size: CGSize = source.size
        UIGraphicsBeginImageContext(size)
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        source.drawInRect(rect, blendMode: .Darken, alpha: 1.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBStrokeColor(context, 255, 255, 255, 1.0)
        CGContextStrokeRectWithWidth(context, rect, 10.0)
        let testImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return testImg
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.txtField.resignFirstResponder()
        print("Se presiono el botón de Search")
        obtenerInformacion()
        return true
    }
    
    func obtenerInformacion () {
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
                self.lblAutors.text = "por \(autores[0]["name"]!)"
                print(self.lblAutors.text)
                
                // Código nuevo para colocar diferentes colores en un mismo label
                let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.lblAutors.attributedText!)
                text.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, 3))
                self.lblAutors.attributedText = text
                // ------------
                
                // Obtenemos el url de la imagen de portada y se lo pasamos a el UIImage
                let covers = diccionarioISBN!["cover"] as! NSDictionary
                
                urlImg = NSURL(string: covers["large"] as! NSString as String)
                
                
            
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
        
        // MARK: Creamos un spinner para dar feedback al usuario que se esta cargando la imagen de portada
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.center = CGPointMake(self.imgPortadaLibro.frame.width / 2.0, self.imgPortadaLibro.frame.height / 2.0)
        self.imgPortadaLibro.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        // ---
        // se crea una sesión compartida
        let sesion = NSURLSession.sharedSession()
        
        // El bloque es el procesameinto y la respuesta de la petición
        let bloque = { (datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
            
           
            
            let dataImg = NSData(contentsOfURL: self.urlImg!)
            
            let imagenLista = UIImage(data: dataImg!)
            
            // MARK: Esto se usa para pasar el proceso de asignar la imagen descargado de la web, al hilo principal, todo lo relacionado con UIKit debe ir en el hilo principal
            if ((imagenLista) != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.imgBackground.image = imagenLista
                    self.imgPortadaLibro.image = self.imageWithBorderFromImage(imagenLista!)
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    

                    });
            }
            
        }
        // Creamos una tarea para la sesión con una llamada Callback
        let dataTask = sesion.dataTaskWithURL(urlImg!, completionHandler: bloque)
        // se empieza la ejecución de la tarea con el método resume
        dataTask.resume()
        // ---


        
    }
}

