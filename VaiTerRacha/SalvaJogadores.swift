//
//  SalvaTimes.swift
//  VaiTerRacha
//
//  Created by Arleson  on 17/03/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import Foundation

class SalvaJogadores {
    let keyDados = "MeusTimes"
    var jogadores: [Dictionary<String,String>] = []
    
    func getDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func salvaJogadores(jogador:Dictionary<String,String>) {
        jogadores = listaJogadores()
        jogadores.append(jogador)
        getDefaults().set(jogadores, forKey: keyDados)
        getDefaults().synchronize()
    }
    
    func listaJogadores() -> [Dictionary<String,String>]{
        let dados = getDefaults().object(forKey: keyDados)
        if dados != nil {
            return dados as! [Dictionary<String,String>]
        }else {
            return []
        }
    }
    
    func apagarJogador(indice:Int) {
        jogadores = listaJogadores()
        jogadores.remove(at: indice)
        getDefaults().set(jogadores, forKey: keyDados)
        getDefaults().synchronize()
    }

}
