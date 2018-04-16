//
//  Jogador.swift
//  VaiTerRacha
//
//  Created by Arleson  on 13/04/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import Foundation

class Jogador {
    
    var id:String
    var nome:String
    var confirmado:String
    
    init(id:String, nome:String, confirmado:String) {
        self.id = id
        self.nome = nome
        self.confirmado = confirmado
    }
}
