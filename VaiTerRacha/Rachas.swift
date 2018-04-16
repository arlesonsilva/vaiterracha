//
//  Rachas.swift
//  VaiTerRacha
//
//  Created by Arleson  on 11/04/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import Foundation

class Racha {
    
    var id:String
    var nome:String
    var hora:String
    var local:String
    var diaSemana:String
    
    init(id:String, nome:String, hora:String, local:String, diaSemana: String) {
        self.id = id
        self.nome = nome
        self.local = local
        self.hora = hora
        self.diaSemana = diaSemana
    }
}
