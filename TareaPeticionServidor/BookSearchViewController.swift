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

class BookSearchViewController: UIViewController, UITextFieldDelegate {
    
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
    
    var currentSearchTask: URLSessionTask?
    var spinner = UIActivityIndicatorView()
    
    var urlImg : URL?
    
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    fileprivate func setupBackgroundImage() {
        // MARK: Efecto Blur
        imgBackground.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = imgBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgBackground.addSubview(blurEffectView)
    }
    
    fileprivate func setupShadowToTitleLabel() {
        lblTituloLibro.shadowColor = UIColor.black
        lblTituloLibro.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    fileprivate func setupNavigationBar() {
        self.navigationController!.navigationBar.barStyle = .blackTranslucent
        self.navigationController!.navigationBar.isTranslucent = true
        let rightSearchBarButtonItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        rightSearchBarButtonItem.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.setRightBarButton(rightSearchBarButtonItem, animated: true)
    }
    
    fileprivate func setupSearchBar() {
        // MARK: Aquí todo lo de el searchBar
        // Can replace logoImageView for titleLabel of navbar
        let logoImage = UIImage()
        logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: logoImage.size.width, height: logoImage.size.height))
        logoImageView.image = logoImage
        navigationItem.titleView = logoImageView
        
        searchBar.tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [BookSearchViewController.self]).tintColor = .lightText
        UITextField.appearance(whenContainedInInstancesOf: [BookSearchViewController.self]).keyboardAppearance = .light
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Ingrese el ISBN"
        
        searchBarButtonItem = navigationItem.rightBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contexto = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        setupBackgroundImage()
        setupShadowToTitleLabel()
        setupNavigationBar()
        setupSearchBar()
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
        DispatchQueue.main.async {
            self.navigationItem.setRightBarButton(self.searchBarButtonItem, animated: true)
            self.logoImageView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationItem.titleView = self.logoImageView
                self.logoImageView.alpha = 1
            }, completion: { finished in
                
            })
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
        context.stroke(rect, width: Device.IS_3_5_INCHES() || Device.IS_4_INCHES() ? 4.5 : 10.0)
        let testImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return testImg
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func setupActivityIndicator() {
        // MARK: Creamos un spinner para dar feedback al usuario que se esta cargando la imagen de portada
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = CGPoint(x: self.imgPortadaLibro.frame.width / 2.0, y: self.imgPortadaLibro.frame.height / 2.0)
        self.imgPortadaLibro.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
    }
    
    fileprivate func setBookTitleLabels(_ book: BookData) {
        // MARK: Establece título del libro
        let title = book.title
        self.lblTituloLibro.text = title
        self.modelo.titulo.append(title)
        self.delegate?.updateData(data: self.modelo)
        self.tituloAMandar = title
    }
    
    fileprivate func setBookAuthorsLabels(_ book: BookData) {
        
        self.lblAutors.text = "Por "
        self.autoresEntidad = ""
        var index: Int = 0
        for author in book.authors {
            if index == book.authors.count - 1 {
                self.autoresEntidad = self.autoresEntidad + author.name
                self.lblAutors.text = self.lblAutors.text! + author.name
            } else {
                self.autoresEntidad = self.autoresEntidad + author.name + ", "
                self.lblAutors.text = self.lblAutors.text! + author.name + ", "
            }
            index += 1
        }
        
        self.autoresAMandar = self.lblAutors.text!
        
        // Código nuevo para colocar diferentes colores en un mismo label
        let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.lblAutors.attributedText!)
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 3))
        self.lblAutors.attributedText = text
    }
    
    private func getCorrectCoverImageUrl(_ book: BookData) -> URL? {
        var urlCover = URL(string: "")
        
        if self.iPhone {
            if Device.IS_3_5_INCHES() {
                urlCover = URL(string: book.cover["small"] ?? "")
            }
            else if Device.IS_4_INCHES() {
                urlCover = URL(string: book.cover["medium"] ?? "")
            }
            else if Device.IS_4_7_INCHES() {
                urlCover = URL(string: book.cover["medium"] ?? "")
            }
            else if Device.IS_5_5_INCHES() {
                urlCover = URL(string: book.cover["large"] ?? "")
            }
        } else {
            urlCover = URL(string: book.cover["large"] ?? "")
        }
        return urlCover
    }
    
    fileprivate func setBookCoverImages(_ book: BookData) -> Data? {
        let data = try! Data(contentsOf: getCorrectCoverImageUrl(book)!)
        self.imgPortadaLibro.image = UIImage(data: data as Data)
        self.imgBackground.image = UIImage(data: data as Data)
        self.imgPortadaLibro.image = self.imageWithBorderFromImage(source: UIImage(data: data as Data)!)
        return data
    }
    
    private func handleBookSearch(obtainedBook: BookData?, error: Error?) {
        
        if let _ = error {
            removeActivityIndicator()
            hideSearchBar()
            self.alert(message: "Hubo un error al intentar encontrar el libro, Intenta de nuevo")
            return
        }
        guard let book = obtainedBook else {
            removeActivityIndicator()
            hideSearchBar()
            self.alert(message: "Hubo un error al intentar encontrar el libro, Intenta de nuevo")
            return
        }
        
        setBookTitleLabels(book)
        setBookAuthorsLabels(book)
        if let dataCover = setBookCoverImages(book) {
            saveBookEntity(dataCover)
        }
        
        self.delegateNuevoDelegado?.mandarTitulo(tituloMandado: self.tituloAMandar, imagenMandada: self.imgPortadaLibro.image!, _autorMandado: self.autoresAMandar)
        removeActivityIndicator()
        hideSearchBar()
    }
    
    private func removeActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
        }
    }
    
    private func saveBookEntity(_ data: Data) {
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
    
    func obtenerInformacion(isbnText: String) {
        self.isbn = isbnText
        setupActivityIndicator()
        ServiceSender.searchBy(isbn: isbnText, completion: handleBookSearch(obtainedBook:error:))
    }
}

extension BookSearchViewController: UISearchBarDelegate {
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
}

extension BookSearchViewController {
    func alert(message : String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

