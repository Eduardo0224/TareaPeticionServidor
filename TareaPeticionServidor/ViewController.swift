//
//  ViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo Andrade based on the code of Osvaldo Aaron Marquez Espinoza on 07/12/15.
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
    
    var iPhone: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
    }
    
    var iPad: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    }
    
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
        
        lblTituloLibro.shadowColor = UIColor.blackColor()
        lblTituloLibro.shadowOffset = CGSize(width: 0, height: 1)
        

    }
    
    func imageWithBorderFromImage(source: UIImage) -> UIImage {
        let size: CGSize = source.size
        UIGraphicsBeginImageContext(size)
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        source.drawInRect(rect, blendMode: .Darken, alpha: 1.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBStrokeColor(context, 255, 255, 255, 1.0)
        
        if Device.IS_3_5_INCHES() || Device.IS_4_INCHES() {
            CGContextStrokeRectWithWidth(context, rect, 4.5)
        }
        else {
            CGContextStrokeRectWithWidth(context, rect, 10.0)
        }
        
        let testImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return testImg
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.txtField.resignFirstResponder()
        print("Se presiono el botón de Search")
        if textField.text != "" {
            obtenerInformacion(txtField.text!)
        }
        else {
            alert("Debe ingresar un ISBN")
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func obtenerInformacion(isbnText: String){
        
        // MARK: Creamos un spinner para dar feedback al usuario que se esta cargando la imagen de portada
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.center = CGPointMake(self.imgPortadaLibro.frame.width / 2.0, self.imgPortadaLibro.frame.height / 2.0)
        self.imgPortadaLibro.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        let apiUrl = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbnText)"
        let url = NSURL(string: apiUrl)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {
            (data, response, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                if((response) != nil){
                    
                    // Los datos obtenidos los codificamos a UTF8
                    let texto = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String

                    self.txtViewResponse.text = texto as String
                    self.txtViewResponse.textColor = UIColor.whiteColor()
                    self.txtViewResponse.font = UIFont(name: "Trebuchet MS", size: 14.0)
                    
                    if texto.containsString(isbnText) {
                        
                        
                        do{
                            let jsonDatos = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            let keyJsonData : String = "ISBN:" + isbnText
                            
                            
                            if let datos = jsonDatos[keyJsonData] as? NSDictionary{
                                
                                if let nombreTitulo = datos["title"] as? String{
                                    self.lblTituloLibro.text = nombreTitulo
                                }
                                
                                if let autores = datos["authors"] as? NSArray{
                                    self.lblAutors.text = "Por "
                                    var index: Int = 0
                                    for nombreAutor in autores {
                                        if index == autores.count - 1 {
                                            self.lblAutors.text = self.lblAutors.text! + (nombreAutor["name"] as! String)
                                        }else{
                                            self.lblAutors.text = self.lblAutors.text! + (nombreAutor["name"] as! String) + ", "
                                        }
                                        ++index
                                    }
                                    
                                    // Código nuevo para colocar diferentes colores en un mismo label
                                    let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.lblAutors.attributedText!)
                                    text.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, 3))
                                    self.lblAutors.attributedText = text
                                    // ------------

                                }
                                
                                if let _ = datos["cover"] as? NSDictionary{
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                        // Obtenemos el url de la imagen de portada y se lo pasamos a el UIImage
                                        let cover = datos["cover"]
                                        if cover != nil && cover is NSDictionary {
                                            let covers = datos["cover"] as! NSDictionary
                                            
                                            if self.iPhone {
                                                if Device.IS_3_5_INCHES() {
                                                    self.urlImg = NSURL(string: covers["small"] as! NSString as String)
                                                    print("3.5 inches")
                                                }
                                                else if Device.IS_4_INCHES() {
                                                    self.urlImg = NSURL(string: covers["medium"] as! NSString as String)
                                                    print("4 inches")
                                                }
                                                else if Device.IS_4_7_INCHES() {
                                                    self.urlImg = NSURL(string: covers["medium"] as! NSString as String)
                                                    print("4.7 inches")
                                                }
                                                else if Device.IS_5_5_INCHES() {
                                                    self.urlImg = NSURL(string: covers["large"] as! NSString as String)
                                                    print("5.5 inches")
                                                }
                                            } else if self.iPad {
                                                self.urlImg = NSURL(string: covers["large"] as! NSString as String)
                                                print("iPad")
                                            }
                                        }


                                        let data = NSData(contentsOfURL: self.urlImg!)
                                        self.imgPortadaLibro.image = UIImage(data: data!)
                                        
                                        self.imgBackground.image = UIImage(data: data!)
                                        self.imgPortadaLibro.image = self.imageWithBorderFromImage(UIImage(data: data!)!)
                                        spinner.stopAnimating()
                                        spinner.removeFromSuperview()

                                    })
                                }
                            }
                        }catch _ {
                            
                        }
                        
                    }else{
                        self.alert("No se encontro información, con el ISBN introducido")
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                    }
                    
                }else{
                    self.alert("Error al conectar, compruebe su conexión a internet")
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                }
            })
        })
        
        task.resume()
    }
    
    func alert(message : String){
        let alertController = UIAlertController(title: "Error al conectar", message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(ok)
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    
}

