//
//  BookData.swift
//  TareaPeticionServidor
//
//  Created by Eduardo Andrade on 7/9/19.
//  Copyright © 2019 EduardoAndrade. All rights reserved.
//

import Foundation

struct BookData: Codable {
    let title: String
    let cover: [String: String]
    let authors: [AuthorData]    
}
