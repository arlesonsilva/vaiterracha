//
//  ViewController.swift
//  VaiTerRacha
//
//  Created by Arleson  on 14/03/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UITableViewController {
    
    var auth:Auth!
    var database: DatabaseReference!
    var rachas: [Racha] = []
    var controleNavegacao = "adicionar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.database = Database.database().reference()
        self.auth = Auth.auth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.topItem?.title = "Vai Ter Racha"
        controleNavegacao = "adicionar"
        atualizaRachas()
    }
    
    @IBAction func sair(_ sender: Any) {
        // deslogar usuario
        do{
            try self.auth.signOut()
            _ = navigationController?.popToRootViewController(animated: true)
        }catch {
            print("Erro ao deslogar usuario")
        }
    }
    
    func atualizaRachas() {
        listaRachas()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rachas.count
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
    
    func listaRachas() {
        let emailB64 = self.recuperaEmailB64User()
        let rachasDB = self.database.child("rachas").child(emailB64)
        rachasDB.observe(.value) { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                //clearing the list
                self.rachas.removeAll()
                
                //iterating through all the values
                for rachas in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let dados = rachas.value as? NSDictionary
                    
                    if let id = dados!["id_racha"] {
                        if let nome = dados!["nome_racha"] {
                            if let local = dados!["local_racha"] {
                                if let hora = dados!["hora_racha"] {
                                    if let diaS = dados!["dia_semana_racha"] {
                                        let racha = Racha(id: id as! String, nome: nome as! String, hora: hora as! String, local: local as! String, diaSemana: diaS as! String)
                                        //appending it to list
                                        self.rachas.append(racha)
                                    }
                                }
                            }
                        }
                    }
                }
                //reloading the tableview
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celulaRachas", for: indexPath)
        
        // Configure the cell...
        let racha = self.rachas[indexPath.row]
        cell.textLabel?.text = racha.nome
        cell.detailTextLabel?.text = racha.diaSemana + " - " + racha.hora
        cell.imageView?.image = #imageLiteral(resourceName: "logo")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //performSegue(withIdentifier: "segueJogadores", sender: indexPath.row)
        //print(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: "Editar" ) { (action, indexPath) in
            self.controleNavegacao = "editar"
            self.performSegue(withIdentifier: "segueCriarRacha", sender: indexPath.row)
        }
        let delete = UITableViewRowAction(style: .default, title: "Deletar" ) { (action, indexPath) in
            self.deleteRacha(indice: indexPath.row)
            self.atualizaRachas()
        }
        edit.backgroundColor = .blue
        delete.backgroundColor = .red
        return [delete,edit]
    }
    
    func deleteRacha(indice:Int) {
        let racha = self.rachas[indice]
        let indice = racha.id
        let emailB64 = self.recuperaEmailB64User()
        let ref = database.child("rachas").child(emailB64).child(indice)
        ref.removeValue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCriarRacha" {
            let viewControllerDestino = segue.destination as! RachaViewController
            if controleNavegacao == "editar" {
                if let indiceReuperado = sender {
                    let indice = indiceReuperado as! Int
                    let racha = self.rachas[indice]
                    viewControllerDestino.indiceSelecionado = racha.id
                }
            }else {
                viewControllerDestino.racha = []
                viewControllerDestino.indiceSelecionado = ""
            }
        }
        if (segue.identifier == "segueJogadores") {
            if let indexPath = tableView.indexPathForSelectedRow {
                let indiceRacha = indexPath.row
                let racha = self.rachas[indiceRacha]
                let tabBar = segue.destination as! TabBarViewController
                let viewControllerDestino = tabBar.viewControllers?.first as! JogadorTableViewController
                let viewControllerDestino2 = tabBar.viewControllers?.last as! TimesViewController
                viewControllerDestino.indiceSelecionado = racha.id
                viewControllerDestino.nomeRacha = racha.nome
                viewControllerDestino2.indiceSelecionado = racha.id
            }
        }
    }
    
    func encodeBase64(text: String) -> String {
        let dados = text.data(using: String.Encoding.utf8)
        let dadosB64 = dados!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return dadosB64
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

