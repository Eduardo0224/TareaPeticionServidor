//
//  Model.swift
//  TareaPeticionServidor
//
//  Created by Eduardo on 11/12/15.
//  Copyright © 2015 EduardoAndrade. All rights reserved.
//

import UIKit

struct Model {
    var titulo : [String] = [String]()
    var autores : [String]?
    var portadas : [UIImage]?
    
//    init (_titulo: [String], _autores: [String], _portadas : [UIImage]) {
//        self.titulo = _titulo
//        self.autores = _autores
//        self.portadas = _portadas
//    }
    
    init(_titulo: [String]) {
        self.titulo = _titulo
    }
    
}
