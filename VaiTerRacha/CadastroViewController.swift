//
//  CadastroViewController.swift
//  VaiTerRacha
//
//  Created by Arleson  on 14/04/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CadastroViewController: UIViewController {

    var auth:Auth!
    var firebase:Database!
    @IBOutlet weak var campoNome: UITextField!
    @IBOutlet weak var campoEmail: UITextField!    
    @IBOutlet weak var campoSenha: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.auth = Auth.auth()
        self.firebase = Database.database()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func btnCadastrar(_ sender: Any) {
        if let email = self.campoEmail.text {
            if let nome = self.campoNome.text {
                if let senha = self.campoSenha.text {
                    //  cadastra usuario no firebase
                    self.auth.createUser(withEmail: email, password: senha, completion: {(usuario, erro) in
                        if erro == nil {
                            var usuario:Dictionary<String,String> = [:]
                            let emailB64 = self.encodeBase64(text: email)
                            usuario["nome_usuario"] = nome
                            usuario["email_usuario"] = email
                            let usuarios = self.firebase.reference().child("usuarios").child(emailB64)
                            usuarios.setValue(usuario)
                            //print("Usuario cadastrado com sucesso!")
                        }else {
                            print("Erro ao tentar cadastrar usuario: \(String(describing: erro?.localizedDescription))")
                        }
                    })
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
