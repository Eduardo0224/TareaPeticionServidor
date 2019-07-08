//
//  DetailViewController.swift
//  TareaPeticionServidor
//
//  Created by Eduardo on 13/12/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var tituloDetalle : String?
    var autoresDetalle : String?
    var portadaDetalle : UIImage?

    @IBOutlet weak var imgPortadaBackground: UIImageView!
    @IBOutlet weak var imgPortada: UIImageView!
    @IBOutlet weak var lblTituloLibro: UILabel!
    @IBOutlet weak var lblAutorLibro: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblTituloLibro.text = tituloDetalle
        lblAutorLibro.text = autoresDetalle
        imgPortada.image = portadaDetalle
        imgPortadaBackground.image = portadaDetalle
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.imgPortadaBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.imgPortadaBackground.addSubview(blurEffectView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
