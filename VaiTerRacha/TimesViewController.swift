//
//  TimesViewController.swift
//  VaiTerRacha
//
//  Created by Arleson  on 13/04/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TimesViewController: UIViewController {
    
    @IBOutlet weak var lbNumeroTimes: UITextField!
    @IBOutlet weak var lbTimesSoteado: UITextView!
    @IBOutlet weak var btnSorteiaTimes: UIButton!
    
    var indiceSelecionado:String!
    var times:[String] = []
    var jogadoresC:[Jogador] = []
    var timesJogadores:[String] = []
    var firebase: DatabaseReference!
    var auth: Auth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebase = Database.database().reference()
        self.auth = Auth.auth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.atualizaJogadores()
    }
    
    func atualizaJogadores() {
        let emailB64 = recuperaEmailB64User()
        let ref = self.firebase.child("jogadores").child(emailB64).child(indiceSelecionado)
        ref.observe(.value) { (snapshot) in
            //clearing the list
            self.jogadoresC.removeAll()
            
            //iterating through all the values
            for jogadores in snapshot.children.allObjects as! [DataSnapshot] {
                //getting values
                let dados = jogadores.value as? NSDictionary
                if let id = dados!["id_jogador"] {
                    if let nome = dados!["nome_jogador"] {
                        if let status = dados!["status_jogador"] {
                            if status as! String == "true" {
                                let jogador = Jogador(id: id as! String, nome: nome as! String, confirmado: status as! String )
                                self.jogadoresC.append(jogador)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func recuperaEmailB64User() -> String {
        if let userLogado = auth.currentUser {
            if let email = userLogado.email {
                let emailB64 = encodeBase64(text: email)
                return emailB64
            }
        }
        return ""
    }
    
    func encodeBase64(text: String) -> String {
        let dados = text.data(using: String.Encoding.utf8)
        let dadosB64 = dados!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return dadosB64
    }
    
    @IBAction func btnSorteioTimes(_ sender: Any) {
        
        let numeroTotalJogadores = jogadoresC.count
        if numeroTotalJogadores == 0 {
            lbTimesSoteado.text = "Nenhum jogador confirmado"
        }
        if let numberJogadoresPorTime = Int(lbNumeroTimes.text!) {
            if numberJogadoresPorTime > 0 {
                let difJogadoresPorTime = numeroTotalJogadores % numberJogadoresPorTime
                let numeroTimes:Int
                if difJogadoresPorTime > 0 {
                    let jogadoresPorTimeMenosDif = numeroTotalJogadores - difJogadoresPorTime
                    numeroTimes = jogadoresPorTimeMenosDif / numberJogadoresPorTime
                }else {
                    numeroTimes = numeroTotalJogadores / numberJogadoresPorTime
                }
                times.removeAll()
                // crio os times
                for i in 1...numeroTimes{
                    times.append("Time \(i)")
                }
                // caso tenha time incompleto crio um time a mais
                if difJogadoresPorTime > 0 {
                    let novoTime = times.count + 1
                    times += ["Time \(novoTime)"]
                }
                timesJogadores.removeAll()
                // faco sorteio dos jogadores para os times
                var array = jogadoresC
                var njpt1 = 0
                var njpt2 = numberJogadoresPorTime
                for i in 0...times.count - 1 {
                    timesJogadores.append("\(times[i]) \n")
                    print(times[i])
                    let arrayTeam = array[njpt1..<njpt2]
                    for j in arrayTeam {
                        print(j.nome)
                        timesJogadores.append("  \(j.nome) \n");
                    }
                    njpt1 = njpt1 + numberJogadoresPorTime
                    njpt2 = njpt2 + numberJogadoresPorTime
                    if njpt2 > array.count {
                        njpt2 = njpt1 + difJogadoresPorTime
                    }
                    timesJogadores.append("\n");
                }
                var res = ""
                for time in timesJogadores {
                    res += "\(time)" //\n \n"
                }
                lbTimesSoteado.text = res
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
