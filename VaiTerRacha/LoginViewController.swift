//
//  LoginViewController.swift
//  VaiTerRacha
//
//  Created by Arleson  on 14/04/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var auth:Auth!
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var campoSenha: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        // verifica se usuario esta logado
        Auth.auth().addStateDidChangeListener({(Auth,usuario) in
            if usuario != nil {
                //print("Usuario logado email: " + String(describing: usuarioLogado.email))
                self.performSegue(withIdentifier: "segueLoginAut", sender: nil)
            }else {
                print("Usuario nao esta logado")
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func btnLogar(_ sender: Any) {
        if let email = self.campoEmail.text {
            if let senha = self.campoSenha.text {
                // login usuario
                self.auth.signIn(withEmail: email, password: senha, completion: { (usuario, erro) in
                    if erro == nil {
                        if let usuarioLogado = usuario {
                            print("Usuario logado com sucesso! \(String(describing: usuarioLogado.email))")
                        }
                    }else {
                        print("Erro ao autenticar usuario: \(String(describing: erro?.localizedDescription))")
                    }
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
