//
//  RachaViewController.swift
//  VaiTerRacha
//
//  Created by Arleson  on 14/03/2018.
//  Copyright © 2018 Arleson Silva. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RachaViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var lbNomeRacha: UITextField!
    @IBOutlet weak var DiasDaSemanaPV: UIPickerView!
    @IBOutlet weak var lbLocalRacha: UITextField!
    @IBOutlet weak var lbDiaSemana: UILabel!
    @IBOutlet weak var lbHoraRacha: UILabel!
    @IBOutlet weak var dpHoraRacha: UIDatePicker!
    
    var firebase:DatabaseReference!
    var auth: Auth!
    
    let diasSemana = ["Segunda","Terça","Quarta","Quinta","Sexta","Sabado","Domingo"]
    var racha:[Racha] = []
    var indiceSelecionado:String!
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firebase = Database.database().reference()
        self.auth = Auth.auth()
        if let indice = indiceSelecionado {
            if !indice.elementsEqual("") {
                editaRacha()
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
    
    func recuperaEmailUser() -> String {
        if let userLogado = auth.currentUser {
            if let email = userLogado.email {
                return email
            }
        }
        return ""
    }
    
    func editaRacha() {
        if let indice = indiceSelecionado  {
            let rachaN = firebase.child("rachas")
            let emailB64 = recuperaEmailB64User()
            let rachaR = rachaN.child(emailB64).child(indice)
            rachaR.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let dados = snapshot.value as! NSDictionary
                //let id = dados["id_racha"] as! String
                let nome = dados["nome_racha"] as! String
                let hora = dados["hora_racha"] as! String
                let local = dados["local_racha"] as! String
                let diaS = dados["dia_semana_racha"] as! String
                
                self.lbNomeRacha.text = nome
                self.lbDiaSemana.text = diaS
                self.lbHoraRacha.text = hora
                self.lbLocalRacha.text = local
                self.DiasDaSemanaPV.selectRow(self.diaSemanaInt(diaS: diaS), inComponent: 0, animated: false)
            })
        }
    }

    func diaSemanaInt(diaS:String) -> Int {
        let dsemana: String = diaS
        var ret: Int = 0
        
        switch dsemana {
        case "Segunda":
            ret = 0
        case "Terça":
            ret = 1
        case "Quarta":
            ret = 2
        case "Quinta":
            ret = 3
        case "Sexta":
            ret = 4
        case "Sabado":
            ret = 5
        case "Domingo":
            ret = 6
        default:
            ret = 0
        }
        return ret
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return diasSemana[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return diasSemana.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lbDiaSemana.text = diasSemana[row]
    }
    
    @IBAction func tpHoraRacha(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mi"
        lbHoraRacha.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnSalvarRacha(_ sender: Any) {
        if let nm_racha = lbNomeRacha.text {
            if let nm_semana = lbDiaSemana.text {
                if let hr_racha = lbHoraRacha.text {
                    if let ds_local = lbLocalRacha.text {
                        if let indice = indiceSelecionado {
                            if !indice.elementsEqual("") {
                                let email = recuperaEmailUser()
                                let emailB64 = encodeBase64(text: email)
                                let ref = firebase.child("rachas").child(emailB64).child(indice)
                                let racha = ["id_racha":"\(indice)",
                                             "nome_racha":"\(nm_racha)",
                                             "dia_semana_racha":"\(nm_semana)",
                                             "hora_racha":"\(hr_racha)",
                                             "local_racha":"\(ds_local)"]
                                ref.updateChildValues(racha)
                            }else {
                                let email = recuperaEmailUser()
                                let emailB64 = encodeBase64(text: email)
                                let key =  firebase.childByAutoId().key
                                let rachas = firebase.child("rachas").child(emailB64).child(key)
                                let racha = ["id_racha":"\(key)",
                                             "nome_racha":"\(nm_racha)",
                                             "dia_semana_racha":"\(nm_semana)",
                                             "hora_racha":"\(hr_racha)",
                                             "local_racha":"\(ds_local)"]
                                rachas.setValue(racha)
                            }
                        }
                        if let composeViewController = self.navigationController?.viewControllers[1] {
                            self.navigationController?.popToViewController(composeViewController, animated: true)
                        }
                    }
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
