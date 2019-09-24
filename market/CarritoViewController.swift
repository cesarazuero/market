//
//  CarritoViewController.swift
//  market
//
//  Created by Cesar Julián Azuero Garavito on 9/24/19.
//  Copyright © 2019 Prueba. All rights reserved.
//

import UIKit
import SDWebImage

class CarritoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //Instancia de controllers
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCantidad: UILabel!
    @IBOutlet weak var txtCantidad: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var txtTotal: UILabel!
    @IBOutlet weak var txtNoItems: UILabel!
    
    
    //Variables generales
    var arrayProductos:[Producto] = [];
    //Instancia de la clase utils
    let utils = Utils();
    //Instancia de la clase de DB
    let storeLocal = StoreLocal();
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        //Le asigno un titulo al view controller
        self.navigationItem.title = NSLocalizedString("titulo_carrito", comment: "titulo_carrito");
        
        //Asigno el texto al holder de no items
        txtNoItems.text = NSLocalizedString("label_no_items", comment: "label_no_items");
        
        do
        {
            try arrayProductos = storeLocal.getAll();
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.reloadData();
        }
        catch{}
        
        updateTotal();
    }
    
    func updateTotal()
    {
        lblCantidad.text = NSLocalizedString("label_cantidad_items", comment: "label_cantidad_items");
        txtCantidad.text = String(arrayProductos.count);
        
        var suma:Float = 0.0;
        
        for i in arrayProductos
        {
            suma = suma + i.precio.floatValue;
        }
        
        lblTotal.text = NSLocalizedString("label_total", comment: "label_total");
        txtTotal.text = utils.formatCurrency(value: NSNumber(value: suma));
        
        if(arrayProductos.count == 0)
        {
            txtNoItems.isHidden = false;
            tableView.isHidden = true;
        }
        else
        {
            txtNoItems.isHidden = true;
            tableView.isHidden = false;
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        //Hay solo una sección en la tabla
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayProductos.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaMain", for: indexPath as IndexPath) as! MainTableViewCell;
        
        let record:Producto = arrayProductos[indexPath.row];
        
        cell.txtNombre.text = record.nombre;
        cell.txtPrecio.text = utils.formatCurrency(value: record.precio);
        cell.imgIcono.sd_setImage(
            with: URL(string:record.ruta_imagen),
            placeholderImage: UIImage(named: "placeholder_image.png"),
            options: SDWebImageOptions(rawValue: 0),
            completed:{ image, error, cacheType, imageURL in
                
        });
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete
        {
            storeLocal.delete(id: arrayProductos[indexPath.row].id);
            arrayProductos.remove(at: indexPath.row);
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic);
            
            updateTotal();
        }
    }
}
