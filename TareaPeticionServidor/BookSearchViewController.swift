//
//  ViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo Andrade based on the code of Osvaldo Aaron Marquez Espinoza on 07/12/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit

protocol BookSearchDelegate {
    func updateData(data: Model)
}

class BookSearchViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {

    var delegate: BookSearchDelegate?

    @IBOutlet weak var lblTituloLibro: UILabel!
    @IBOutlet weak var lblAutors: UILabel!
    @IBOutlet weak var imgPortadaLibro: UIImageView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    
    // MARK: UISearchBar
    var searchBar = UISearchBar()
    var searchBarButtonItem: UIBarButtonItem?
    var logoImageView   : UIImageView!
    
    var modelo : Model = Model(_titulo: [])

    
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
        
        // Cambiar el color de la barra de estado
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
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
        

        // Esto sirve para hacer la barra de navegación transparente
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController!.navigationBar.shadowImage = UIImage()
//        self.navigationController!.navigationBar.translucent = true
//        self.navigationController!.view.backgroundColor = UIColor.clearColor()
        
        self.navigationController!.navigationBar.barStyle = .BlackTranslucent;
        self.navigationController!.navigationBar.translucent = true;


        let rightSearchBarButtonItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: Selector("showSearchBar"))
        rightSearchBarButtonItem.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(rightSearchBarButtonItem, animated: true)

        
        // MARK: Aquí todo lo de el searchBar
        // Can replace logoImageView for titleLabel of navbar
        let logoImage = UIImage()
        logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: logoImage.size.width, height: logoImage.size.height))
        logoImageView.image = logoImage
        navigationItem.titleView = logoImageView
        
        searchBar.tintColor = UIColor.whiteColor()
        UITextField.appearanceWhenContainedInInstancesOfClasses([BookSearchViewController.self]).keyboardAppearance = .Light
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBarStyle.Default
        searchBar.placeholder = "Ingrese el ISBN"

        searchBarButtonItem = navigationItem.rightBarButtonItem
        
        /* Esto se usa para cambiarle el color al texto del texfield del searcbar
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        */
        

    }
    
    
    
    // MARK: Métodos de UISearchBar
    func showSearchBar() {

        navigationItem.titleView = searchBar
        searchBar.alpha = 0
        navigationItem.setRightBarButtonItem(nil, animated: true)
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 1
            }, completion: { finished in
                self.searchBar.becomeFirstResponder()
        })
    }
    
    func hideSearchBar() {
        navigationItem.setRightBarButtonItem(searchBarButtonItem, animated: true)
        logoImageView.alpha = 0
        UIView.animateWithDuration(0.3, animations: {
            self.navigationItem.titleView = self.logoImageView
            self.logoImageView.alpha = 1
            }, completion: { finished in
                
        })
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("Se presiono el botón de Search")
        if searchBar.text != "" {
            // le dice al delegado que el botón de de cancel ha sido presionado
            searchBarCancelButtonClicked(searchBar)
            obtenerInformacion(searchBar.text!)
            searchBar.text = ""
        }
        else {
            alert("Debe ingresar un ISBN")
        }
        
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
                    
                    if texto.containsString(isbnText) {                        
                        
                        do{
                            let jsonDatos = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            let keyJsonData : String = "ISBN:" + isbnText
                            
                            
                            if let datos = jsonDatos[keyJsonData] as? NSDictionary{
                                
                                if let nombreTitulo = datos["title"] as? String{
                                    self.lblTituloLibro.text = nombreTitulo
                                    
                                    // Agregamos el título consultado al modelo
                                    self.modelo.titulo.append(nombreTitulo)
                                    print(self.modelo)
                                    
                                    self.delegate?.updateData(self.modelo)
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

