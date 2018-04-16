//
//  SalvaRachas.swift
//  VaiTerRacha
//
//  Created by Arleson  on 14/03/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit

class SalvaRachas {
    
    let keyDados = "MeusRachas"
    var rachas: [Dictionary<String,String>] = []
    
    func getDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func salvaRachas(racha:Dictionary<String,String>) {
        rachas = listaRachas()
        rachas.append(racha)
        getDefaults().set(rachas, forKey: keyDados)
        getDefaults().synchronize()
    }
    
    func listaRachas() -> [Dictionary<String,String>]{
        let dados = getDefaults().object(forKey: keyDados)
        if dados != nil {
            return dados as! [Dictionary<String, String>]
        }else {
            return []
        }
    }
    
    func apagarRacha(indice:Int) {
        rachas = listaRachas()
        rachas.remove(at: indice)
        getDefaults().set(rachas, forKey: keyDados)
        getDefaults().synchronize()
    }
    
    func editaRacha(indice:Int,racha:Dictionary<String,String>) {
        rachas = listaRachas()
        rachas[indice] = racha
        getDefaults().set(rachas, forKey: keyDados)
        getDefaults().synchronize()
    }
    
}
