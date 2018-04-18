//
//  JogadorTableViewController.swift
//  VaiTerRacha
//
//  Created by Arleson  on 17/03/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class JogadorTableViewController: UITableViewController {
    
    var jogadoresC: [Jogador] = []
    var jogadores: [Jogador] = []
    var indiceSelecionado:String!
    var nomeRacha:String!
    var countRowsSection0:Int = 0
    var countRowsSection1:Int = 0
    var firebase: DatabaseReference!
    var auth: Auth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebase = Database.database().reference()
        self.auth = Auth.auth()
        if let nome = nomeRacha {
            self.navigationController?.navigationBar.topItem?.title = nome
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        atualizaJogadores()
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
    
    func atualizaJogadores() {
        let emailB64 = recuperaEmailB64User()
        let ref = self.firebase.child("jogadores").child(emailB64).child(indiceSelecionado)
        ref.observe(.value) { (snapshot) in
            //clearing the list
            self.jogadoresC.removeAll()
            self.jogadores.removeAll()
            
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
                            }else {
                                let jogador = Jogador(id: id as! String, nome: nome as! String, confirmado: status as! String )
                                self.jogadores.append(jogador)
                            }
                        }
                    }
                }
            }
            //reloading the tableview
            self.countRowsSection0 = self.jogadoresC.count
            self.countRowsSection1 = self.jogadores.count
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addJogador(_ sender: Any) {
        let alert = UIAlertController(title: "Nome jogador", message: "Digite o nome do jogador", preferredStyle: .alert)
        let action = UIAlertAction(title: "Salvar", style: .default) { (acao) in
            if let nm_jogador = alert.textFields![0].text {
                let nome_jogador = nm_jogador
                if nome_jogador != "" {
                    if let indice = self.indiceSelecionado {
                        let emailB64 = self.recuperaEmailB64User()
                        let key = indice
                        let id = self.firebase.childByAutoId().key
                        let ref = self.firebase.child("jogadores").child(emailB64).child(key).child(id)
                        let jogador = ["id_jogador":"\(id)",
                                        "nome_jogador":"\(nm_jogador)",
                                        "status_jogador":"false"
                                      ]
                        ref.setValue(jogador)
                        self.atualizaJogadores()
                    }
                }
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Digite o nome do jogador aqui..."
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: "Editar" ) { (action, indexPath) in
            self.editaJogador(indice: indexPath.row, section: indexPath.section)
        }
        let delete = UITableViewRowAction(style: .default, title: "Deletar" ) { (action, indexPath) in
            self.deleteJogador(indice: indexPath.row, section: indexPath.section)
            self.atualizaJogadores()
        }
        edit.backgroundColor = .blue
        delete.backgroundColor = .red
        return [delete,edit]
    }
    
    func editaJogador(indice:Int, section:Int) {
        let alert = UIAlertController(title: "Nome jogador", message: "Digite o nome do jogador", preferredStyle: .alert)
        let action = UIAlertAction(title: "Salvar", style: .default) { (acao) in
            if let nm_jogador = alert.textFields![0].text {
                let nome_jogador = nm_jogador
                if nome_jogador != "" {
                    let jogador:Jogador
                    print("\(indice) \(section)")
                    if section == 0 {
                        jogador = self.jogadoresC[indice]
                    }else {
                        jogador = self.jogadores[indice]
                    }
                    jogador.nome = nome_jogador
                    let emailB64 = self.recuperaEmailB64User()
                    let id = jogador.id
                    let ref = self.firebase.child("jogadores").child(emailB64).child(self.indiceSelecionado).child(id)
                    let jogadore = ["id_jogador":"\(id)",
                                    "nome_jogador":"\(nome_jogador)",
                                    "status_jogador":"\(jogador.confirmado)"
                                   ]
                    ref.updateChildValues(jogadore)
                }
            }
        }
        alert.addTextField { (textField) in
            let jogador:Jogador
            if section == 0 {
                jogador = self.jogadoresC[indice]
            }else {
                jogador = self.jogadores[indice]
            }
            let nome_jogador = jogador.nome
            textField.placeholder = "Digite o nome do jogador aqui..."
            textField.text = nome_jogador
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteJogador(indice:Int, section:Int) {
        let jogador:Jogador
        if section == 0 {
            jogador = self.jogadoresC[indice]
        }else {
            jogador = self.jogadores[indice]
        }
        let indice = jogador.id
        let emailB64 = self.recuperaEmailB64User()
        let ref = firebase.child("jogadores").child(emailB64).child(indiceSelecionado).child(indice)
        ref.removeValue()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Confirmados - \(countRowsSection0)"
        }else {
            return "Não Confirmados - \(countRowsSection1)"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return jogadoresC.count
        }else {
            return jogadores.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let jogador:Jogador
        if indexPath.section == 0 {
            jogador = self.jogadoresC[indexPath.row]
        }else {
            jogador = self.jogadores[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "celulaJogador", for: indexPath)
        
        cell.textLabel?.text = jogador.nome
        //cell.imageView?.image = #imageLiteral(resourceName: "ball")
        
        let lightSwitch = UISwitch(frame: .zero) as UISwitch
        
        if jogador.confirmado == "false" {
            lightSwitch.isOn = false
        }else {
            lightSwitch.isOn = true
        }
        
        lightSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
        lightSwitch.tag = indexPath.row
        cell.accessoryView = lightSwitch
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let jogador:Jogador
        if indexPath.section == 0 {
            jogador = jogadoresC[indexPath.row]
        }else {
            jogador = jogadores[indexPath.row]
        }
        print(jogador.nome)
    }
    
    @objc func switchTriggered(sender: AnyObject) {
        if let indexPath = sender.tag {
            if sender.isOn {
                print("on \(indexPath)")
                confirmaJogador(index: indexPath,section: 0)
            }else {
                print("off \(indexPath)")
                desconfirmaJogador(index: indexPath,section: 1)
            }
        }
        
    }
    
    func confirmaJogador(index:Int,section:Int) {
        let jogador = self.jogadores[index]
        let emailB64 = self.recuperaEmailB64User()
        let id = jogador.id
        let nome_jogador = jogador.nome
        let ref = self.firebase.child("jogadores").child(emailB64).child(self.indiceSelecionado).child(id)
        let jogadore = ["id_jogador":"\(id)",
                        "nome_jogador":"\(nome_jogador)",
                        "status_jogador":"true"
                       ]
        ref.updateChildValues(jogadore)
    }
    
    func desconfirmaJogador(index:Int,section:Int) {
        let jogador = self.jogadoresC[index]
        let emailB64 = self.recuperaEmailB64User()
        let id = jogador.id
        let nome_jogador = jogador.nome
        let ref = self.firebase.child("jogadores").child(emailB64).child(self.indiceSelecionado).child(id)
        let jogadore = ["id_jogador":"\(id)",
                        "nome_jogador":"\(nome_jogador)",
                        "status_jogador":"false"
                       ]
        ref.updateChildValues(jogadore)
    }
    
    func encodeBase64(text: String) -> String {
        let dados = text.data(using: String.Encoding.utf8)
        let dadosB64 = dados!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return dadosB64
    }

}
