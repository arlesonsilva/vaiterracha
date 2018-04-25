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
import Darwin

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
        self.checkIfExistsTimes()
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
    
    func retornaTimesSorteados() {
        let emailB64 = recuperaEmailB64User()
        let ref = self.firebase.child("times").child(emailB64).child(indiceSelecionado)
        ref.observe(.value) { (snapshot) in
            //iterating through all the values
            for times in snapshot.children.allObjects as! [DataSnapshot] {
                //getting values
                let dados = times.value as? String
                self.lbTimesSoteado.text = self.lbTimesSoteado.text + dados!
            }
        }
    }
    
    func checkIfExistsTimes() {
        let indice = self.indiceSelecionado
        let emailB64 = self.recuperaEmailB64User()
        self.firebase.child("times").child(emailB64).child(indice!).observe(DataEventType .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 { //}.hasChild("room1"){
                self.lbNumeroTimes.isEnabled = false
                self.btnSorteiaTimes.isEnabled = false
                self.retornaTimesSorteados()
            }else{
                self.lbNumeroTimes.isEnabled = true
                self.btnSorteiaTimes.isEnabled = true
            }
        })
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
        self.shuffle()
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
                    let arrayTeam = array[njpt1..<njpt2]
                    for j in arrayTeam {
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
                // salva times no firebase
                if let indice = self.indiceSelecionado {
                    let emailB64 = self.recuperaEmailB64User()
                    let key = indice
                    let ref = self.firebase.child("times").child(emailB64).child(key)
                    ref.setValue(timesJogadores)
                }
                lbTimesSoteado.text = res
                lbNumeroTimes.isEnabled = false
                btnSorteiaTimes.isEnabled = false
            }
        }
    }
    
    func shuffle() {
        for _ in 0..<jogadoresC.count
        {
            let rand = Int(arc4random_uniform(UInt32(jogadoresC.count)))
            jogadoresC.append(jogadoresC[rand])
            jogadoresC.remove(at: rand)
        }
    }
    
    // share text
    @IBAction func btnCompartilharTimes(_ sender: Any) {
        
        // text to share
        let timesSorteado = String( lbTimesSoteado.text )
        
        // set up activity view controller
        let textToShare = [ timesSorteado ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
