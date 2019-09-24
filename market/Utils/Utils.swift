//
//  Utils.swift
//
//  Created by Cesar Julián Azuero Garavito on 9/16/16.
//  Copyright © 2016 Cesar Julián Azuero Garavito. All rights reserved.
//

import Foundation
import UIKit
/**
 Clase de varias utilidades: validar email, validar password1, validar password 2, dar formato a moneda, convertir un
 string a un array de caracteres
 */
class Utils
{
    /**
     Función para validar un email
     :param: testStr String Email a validar
     :returns: Bool true si es una dirección de email válida, false si no lo es.
     */
    func isValidEmail(_ testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    /**
     Un valor entero lo convierte a un String del tipo $1456.000
     
     :param: value Int valor a ser formateado
     :returns: String cadena con el valor formateado
     */
    func formatCurrency(value: NSNumber) -> String
    {
        let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2;
            formatter.locale = Locale(identifier: "en_US")
        let result = formatter.string(from: value);
        
        return result!;
    }
    /**
     Convierte un String a un array de caracteres
     
     :param: string String string a ser convertido en array de caracteres
     
     :returns: [Character]
     */
    func StringToCharactersArray(string:String) -> [Character]
    {
        var array = [Character]()
        for element in string.characters
        {
            array.append(element);
        }
        
        return array;
    }
}
