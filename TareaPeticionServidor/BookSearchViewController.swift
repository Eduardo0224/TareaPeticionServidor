//
//  ViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo Andrade based on the code of Osvaldo Aaron Marquez Espinoza on 07/12/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit
import CoreData

protocol BookSearchDelegate {
    func updateData(data: Model)
}

protocol NuevoDelegado {
    func mandarTitulo(tituloMandado : String, imagenMandada: UIImage, _autorMandado: String)
}

class BookSearchViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {
    
    // nos permite acceder al contexto de la pila de core data
    var contexto : NSManagedObjectContext? = nil

    var delegate: BookSearchDelegate?
    var delegateNuevoDelegado : NuevoDelegado?
    
    var tituloAMandar = ""
    var autoresAMandar = ""
    var autoresEntidad = ""
    var isbn : String? = nil

    @IBOutlet weak var lblTituloLibro: UILabel!
    @IBOutlet weak var lblAutors: UILabel!
    @IBOutlet weak var imgPortadaLibro: UIImageView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    
    // MARK: UISearchBar
    var searchBar = UISearchBar()
    var searchBarButtonItem: UIBarButtonItem?
    var logoImageView   : UIImageView!
    
    var modelo : Model = Model(_titulo: [])

    
    var urlImg : URL?
    
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    // Establecemos la dirección del servidor
    var urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contexto = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        // MARK: Efecto Blur
        imgBackground.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = imgBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imgBackground.addSubview(blurEffectView)
        
        lblTituloLibro.shadowColor = UIColor.black
        lblTituloLibro.shadowOffset = CGSize(width: 0, height: 1)
        
        self.navigationController!.navigationBar.barStyle = .blackTranslucent;
        self.navigationController!.navigationBar.isTranslucent = true;


        let rightSearchBarButtonItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        rightSearchBarButtonItem.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.setRightBarButton(rightSearchBarButtonItem, animated: true)

        
        // MARK: Aquí todo lo de el searchBar
        // Can replace logoImageView for titleLabel of navbar
        let logoImage = UIImage()
        logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: logoImage.size.width, height: logoImage.size.height))
        logoImageView.image = logoImage
        navigationItem.titleView = logoImageView
        
        searchBar.tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [BookSearchViewController.self]).tintColor = .lightText
//        UITextField.appearanceWhenContainedInInstancesOfClasses([BookSearchViewController.self]).keyboardAppearance = .light
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Ingrese el ISBN"

        searchBarButtonItem = navigationItem.rightBarButtonItem
    }
    
    // Cambiar el color de la barra de estado
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Métodos de UISearchBar
    @objc func showSearchBar() {

        navigationItem.titleView = searchBar
        searchBar.alpha = 0
        navigationItem.setRightBarButton(nil, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
            }, completion: { finished in
                self.searchBar.becomeFirstResponder()
        })
    }
    
    func hideSearchBar() {
        navigationItem.setRightBarButton(searchBarButtonItem, animated: true)
        logoImageView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationItem.titleView = self.logoImageView
            self.logoImageView.alpha = 1
            }, completion: { finished in
                
        })
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text != "" {
            // le dice al delegado que el botón de de cancel ha sido presionado
            searchBarCancelButtonClicked(searchBar)

            
            // Antes de hacer la busqueda consultar si ese terminó ya fue consultado
            let libroEntidad = NSEntityDescription.entity(forEntityName: "Libro", in: self.contexto!)
            
            // Hacer la petición
            let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplate(withName: "peticionLibro", substitutionVariables: ["isbn": searchBar.text!])
            
            do {
                let libroEntidad2 = try self.contexto?.fetch(peticion!) as! [NSObject]
                // Si arroja un valor es que ya se había hechp esa consulta anteriormente
                if libroEntidad2.count > 0 {
                    // ya se realizo la consulta antes
                    // ya no se hace nada
                    print("Debe salir de aquí")
                    
                    let tituloEntidad = libroEntidad2[libroEntidad2.count - 1].value(forKey: "titulo") as! String
                    let autorEntidad = libroEntidad2[libroEntidad2.count - 1].value(forKey: "autor") as! String
                    
                    let bSVC = BookSearchViewController()
                    let portadaEntidadBackground = UIImage(data: (libroEntidad2[libroEntidad2.count - 1].value(forKey: "portada") as! NSData) as Data)
                    let portadaEntidad = bSVC.imageWithBorderFromImage(source: UIImage(data: (libroEntidad2[libroEntidad2.count - 1].value(forKey: "portada")  as! NSData) as Data)!)
                    
                    lblAutors.text = autorEntidad
                    lblTituloLibro.text = tituloEntidad
                    imgPortadaLibro.image = portadaEntidad
                    imgBackground.image = portadaEntidadBackground
                    
                    searchBar.text = ""
                    return
                }
            }
            catch {
                
            }
            
            obtenerInformacion(isbnText: searchBar.text!)
            searchBar.text = ""
            
        }
        else {
            alert(message: "Debe ingresar un ISBN")
        }
        
    }
    
    func crearImagenEntidad(imagenPortadaLista : UIImage) -> NSObject {
        var entidadADevolver : NSObject? = nil
        
        let imagenEntidad = NSEntityDescription.insertNewObject(forEntityName: "Libro", into: self.contexto!)
        imagenEntidad.setValue(imagenPortadaLista.pngData(), forKey: "portada")
        entidadADevolver = imagenEntidad as NSObject
        return entidadADevolver!
    }

    
    
    func imageWithBorderFromImage(source: UIImage) -> UIImage {
        let size: CGSize = source.size
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        source.draw(in: rect, blendMode: .darken, alpha: 1.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.white.cgColor)
        
        
        if Device.IS_3_5_INCHES() || Device.IS_4_INCHES() {
            context.stroke(rect, width: 4.5)
        }
        else {
            context.stroke(rect, width: 10.0)
        }
        
        let testImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return testImg
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func obtenerInformacion(isbnText: String){
        
        // MARK: Creamos un spinner para dar feedback al usuario que se esta cargando la imagen de portada
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = CGPoint(x: self.imgPortadaLibro.frame.width / 2.0, y: self.imgPortadaLibro.frame.height / 2.0)
        self.imgPortadaLibro.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        let apiUrl = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbnText)"
        let url = URL(string: apiUrl)
        
        URLSession.shared.dataTask(with: url!) { (data, res, err) in
            
        }
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            
            DispatchQueue.main.async {
                if((response) != nil){
                    
                    // Los datos obtenidos los codificamos a UTF8
                    let texto = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    if texto.contains(isbnText) {
                        
                        do{
                            let jsonDatos = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            let keyJsonData : String = "ISBN:" + isbnText
                            
                            self.isbn = isbnText
                            
                            
                            if let datos = jsonDatos[keyJsonData] as? NSDictionary{
                                
                                
                                if let nombreTitulo = datos["title"] as? String{
                                    self.lblTituloLibro.text = nombreTitulo
                                    
                                    // Agregamos el título consultado al modelo
                                    self.modelo.titulo.append(nombreTitulo)
                                    
                                    self.delegate?.updateData(data: self.modelo)
                                    
                                    self.tituloAMandar = nombreTitulo
                                    
                                }
                                
                                if let autores = datos["authors"] as? [[String : Any]] {
                                   
                                    self.lblAutors.text = "Por "
                                    self.autoresEntidad = ""
                                    var index: Int = 0
                                    for nombreAutor in autores {
                                        
                                        if index == autores.count - 1 {
                                            
                                            
                                            self.autoresEntidad = self.autoresEntidad + (nombreAutor["name"] as! String)
                                            self.lblAutors.text = self.lblAutors.text! + (nombreAutor["name"] as! String)
                                        }else{
                                            self.autoresEntidad = self.autoresEntidad + (nombreAutor["name"] as! String) + ", "
                                            self.lblAutors.text = self.lblAutors.text! + (nombreAutor["name"] as! String) + ", "
                                        }
                                        index += 1
                                    }
                                    
                                    
                                    self.autoresAMandar = self.lblAutors.text!
                                    
                                    // Código nuevo para colocar diferentes colores en un mismo label
                                    let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.lblAutors.attributedText!)
                                    text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 3))
                                    self.lblAutors.attributedText = text
                                    // ------------

                                }
                                
                                if let covers = datos["cover"] as? [String: Any] {
                                    DispatchQueue.main.async {
                                        
                                        // Obtenemos el url de la imagen de portada y se lo pasamos a el UIImage
//                                        let cover = datos["cover"]
//                                        if cover != nil && cover is NSDictionary {
//                                            let covers = datos["cover"] as! NSDictionary
//
//
//                                        }
                                        
                                        var urlImage = URL(string: covers["medium"] as! String)
                                        
                                        if self.iPhone {
                                            if Device.IS_3_5_INCHES() {
                                                urlImage = URL(string: covers["small"] as! String)
                                            }
                                            else if Device.IS_4_INCHES() {
                                                urlImage = URL(string: covers["medium"] as! String)
                                            }
                                            else if Device.IS_4_7_INCHES() {
                                                urlImage = URL(string: covers["medium"] as! String)
                                            }
                                            else if Device.IS_5_5_INCHES() {
                                                urlImage = URL(string: covers["large"] as!String)
                                            }
                                        } else {
                                            urlImage = URL(string: covers["large"] as! String)
                                        }
                                        
                                        
                                        let data = try! Data(contentsOf: urlImage!)
                                        self.imgPortadaLibro.image = UIImage(data: data as Data)
                                        
                                        self.imgBackground.image = UIImage(data: data as Data)
                                        self.imgPortadaLibro.image = self.imageWithBorderFromImage(source: UIImage(data: data as Data)!)
                                        
                                        
                                        self.delegateNuevoDelegado?.mandarTitulo(tituloMandado: self.tituloAMandar, imagenMandada: self.imgPortadaLibro.image!, _autorMandado: self.autoresAMandar)
                                        spinner.stopAnimating()
                                        spinner.removeFromSuperview()
                                        
                                        let nuevoLibroEntidad  = NSEntityDescription.insertNewObject(forEntityName: "Libro", into: self.contexto!)
                                        nuevoLibroEntidad.setValue(self.tituloAMandar, forKey: "titulo")
                                        
                                        // alamcenar imagen
                                        nuevoLibroEntidad.setValue(data, forKey: "portada")
                                        // almacenar titulo
                                        nuevoLibroEntidad.setValue(self.autoresEntidad, forKey: "autor")
                                        // almacenar el ISBN
                                        nuevoLibroEntidad.setValue(self.isbn, forKey: "isbn")
                                        
                                        do {
                                            try self.contexto?.save()
                                        }
                                        catch {
                                        }

                                    }
                                }
                            }
                        }catch _ {
                            
                        }
                        
                    }else{
                        self.alert(message: "No se encontro información, con el ISBN introducido")
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                    }
                    
                }else{
                    self.alert(message: "Error al conectar, compruebe su conexión a internet")
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                }
            }
        }
        
        task.resume()
    }
    
    func alert(message : String){
        let alertController = UIAlertController(title: "Error al conectar", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }
    
   
    
    

    
    
}

