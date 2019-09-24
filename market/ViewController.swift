//
//  ViewController.swift
//  market
//
//  Created by Cesar Julián Azuero Garavito on 9/23/19.
//  Copyright © 2019 Prueba. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //Referencias a controles
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var preloader: UIView!
    
    //Variables
    //Array donde almaceno los productos obtenidos desde la API
    var arrayProductos: [Producto]!;
    //Instancia de la clase utils
    let utils = Utils();
    ///View que se coloca encima del contenido para que se oscurezca la pantalla
    var overlay:UIView!;
    //Variable que me indica el tipo de filtro a usar en la búsqueda
    var filtro:String = "todos";
    ///Instancia de la clase que guarda los datos de usuario en la base de datos local.
    let storeLocal:StoreLocal = StoreLocal();
    //Instancia del boton de carrito
    var btnCarrito:UIBarButtonItem!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Le asigno un titulo al view controller
        self.navigationItem.title = NSLocalizedString("titulo_main", comment: "titulo_main");
        //Cargo los productos
        cargarProductos();
        //Creo el boton para filtrar
        let btnFiltrar = UIBarButtonItem(title: NSLocalizedString("label_boton_filtrar", comment: "label_boton_filtrar"), style: .plain,
            target: self,
            action: #selector(mostrarFiltro(_:)));
        self.navigationItem.leftBarButtonItem = btnFiltrar;
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        var cantidad:Int = 0;
        
        do
        {
            try cantidad = storeLocal.getAll().count;
        }
        catch{}
        //Creo el boton para filtrar
        btnCarrito = UIBarButtonItem(title: NSLocalizedString("label_boton_carrito", comment: "label_boton_carrito") + "(\(cantidad))", style: .plain,
                                         target: self,
                                         action: #selector(mostrarCarrito(_:)));
        self.navigationItem.rightBarButtonItem = btnCarrito;
    }
    
    func cargarProductos()
    {
        /*
         Creo el overlay y lo agrego a la vista
         */
        overlay = UIView(frame: view.frame)
        overlay.backgroundColor = UIColor.black;
        overlay.alpha = 0.8
        
        preloader.isHidden = false;
        
        view.addSubview(overlay);
        view.addSubview(preloader);
        /*
         Los parametros para la API
         Son ApiKey y el fomato en que son devueltos, que para mí es JSON.
         */
        let parametros = ["apiKey": NSLocalizedString("api_key_best_buy", comment: "api_key_best_buy"),
                          "format": "json"];
        
        var url:String!;
        
        if(filtro == "todos")
        {
            url = NSLocalizedString("url_productos", comment: "url_productos");
        }
        else
        {
            url = NSLocalizedString("url_productos", comment: "url_productos") + "(type=\(filtro))";
        }
        
        Alamofire.request(url,
                          method: .get,
                          parameters: parametros).responseJSON
            {
                response in
                //Oculto el preloader
                self.overlay.removeFromSuperview();
                self.preloader.isHidden = true;
                
                switch response.result
                {
                case .success(let JSON):
                    let response = JSON as! NSDictionary;
                    
                    self.arrayProductos = [Producto]();
                    
                    if let array:[AnyObject] = response.object(forKey: "products") as! [AnyObject]!
                    {
                        for item in array
                        {
                            let producto = Producto();
                            //Obtengo el nombre del producto y descarto los valores nulos y/o vacios
                            if let nombre:AnyObject = item.object(forKey: "name") as AnyObject?
                            {
                                if !(nombre is NSNull)
                                {
                                    if(nombre as! String != "")
                                    {
                                        producto.nombre = nombre as! String;
                                    }
                                }
                            }
                            //Obtengo el precio del producto y descarto los valores nulos
                            if let precio:AnyObject = item.object(forKey: "regularPrice") as AnyObject?
                            {
                                if !(precio is NSNull)
                                {
                                    producto.precio = precio as! NSNumber;
                                }
                            }
                            //Obtengo la imagen del producto y descarto los valores nulos y/o vacios
                            if let ruta:AnyObject = item.object(forKey: "thumbnailImage") as AnyObject?
                            {
                                if !(ruta is NSNull)
                                {
                                    if(ruta as! String != "")
                                    {
                                        producto.ruta_imagen = ruta as! String;
                                    }
                                }
                            }
                            
                            //Almaceno el product Id
                            producto.id = (item.object(forKey: "sku") as! NSNumber).stringValue;
                            
                            //Almaceno el producto en el array
                            self.arrayProductos.append(producto);
                            //El datasource y el delegate están dentro esta misma clase
                            self.tableView.dataSource = self;
                            self.tableView.delegate = self;
                            self.tableView.reloadData();
                        }
                    }
                    
                case .failure(let _):
                    let alertController = UIAlertController(
                        title: NSLocalizedString("titulo_alerta_lo_sentimos",comment:"titulo_alerta_lo_sentimos"),
                        message: NSLocalizedString("mensaje_error_carga_inicio",comment:"mensaje_error_carga_inicio"),
                        preferredStyle: UIAlertController.Style.alert);
                    
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("label_boton_cerrar",comment:"label_boton_cerrar"),
                                                            style: UIAlertAction.Style.default,
                                                            handler:
                        {
                            (alert:UIAlertAction!) -> Void in
                    }));
                    
                    self.present(alertController, animated: true, completion: nil);
                }
        }
    }
    
    @objc func mostrarFiltro(_ sender:AnyObject)
    {
        let optionMenu = UIAlertController(
            title: nil,
            message: NSLocalizedString("titulo_alerta_filtrar_por",comment:"titulo_alerta_filtrar_por"),
            preferredStyle: .actionSheet);
        
        let musicaAction = UIAlertAction(
            title: NSLocalizedString("label_musica",comment:"label_musica"),
            style: .default,
            handler:
            {
                (alert: UIAlertAction!) -> Void in
                self.filtro = "music";
                self.cargarProductos();
            });
        
        let juegosAction = UIAlertAction(
            title: NSLocalizedString("label_juegos",comment:"label_juegos"),
            style: .default,
            handler:
            {
                (alert: UIAlertAction!) -> Void in
                self.filtro = "game";
                self.cargarProductos();
            });
        
        let peliculasAction = UIAlertAction(
            title: NSLocalizedString("label_peliculas",comment:"label_peliculas"),
            style: .default,
            handler:
            {
                (alert: UIAlertAction!) -> Void in
                self.filtro = "movie";
                self.cargarProductos();
            });
        
        let todosAction = UIAlertAction(
            title: NSLocalizedString("label_todos",comment:"label_todos"),
            style: .default,
            handler:
            {
                (alert: UIAlertAction!) -> Void in
                self.filtro = "todos";
                self.cargarProductos();
        });
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("label_boton_cerrar",comment:"label_boton_cerrar"),
            style: .cancel,
            handler:
            {
                (alert: UIAlertAction!) -> Void in
            });
        
        optionMenu.addAction(musicaAction)
        optionMenu.addAction(juegosAction)
        optionMenu.addAction(peliculasAction)
        optionMenu.addAction(todosAction)
        optionMenu.addAction(cancelAction)
        
        optionMenu.popoverPresentationController?.sourceView = sender.view;
        optionMenu.popoverPresentationController?.sourceRect = sender.view.bounds;
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func mostrarCarrito(_ sender:AnyObject)
    {
        performSegue(withIdentifier: "segueCarrito", sender: self);
    }
    
    @objc func OnTapImage(_ sender:AnyObject)
    {
        let alertController = UIAlertController(
            title: NSLocalizedString("titulo_alerta_confirmar",comment:"titulo_alerta_confirmar"),
            message: NSLocalizedString("mensaje_agregar_carrito",comment:"mensaje_agregar_carrito"),
            preferredStyle: UIAlertController.Style.alert);
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("label_boton_si",comment:"label_boton_si"),
                                                style: UIAlertAction.Style.default,
                                                handler:
        {
            (alert:UIAlertAction!) -> Void in
            
            self.storeLocal.insert(producto: self.arrayProductos[sender.view.tag]);
            
            //Actualizo el "badge"
            self.updateBadge();
        }));
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("label_boton_no",comment:"label_boton_no"),
                                                style: UIAlertAction.Style.default,
                                                handler:
        {
            (alert:UIAlertAction!) -> Void in
        }));
        
        self.present(alertController, animated: true, completion: nil);
    }
    
    func updateBadge()
    {
        do
        {
            let arrayCarrito = try storeLocal.getAll();
            btnCarrito.title = NSLocalizedString("label_boton_carrito", comment: "label_boton_carrito") + "(\(arrayCarrito.count))";
        }
        catch{}
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
        
        //Asigno el detector de gestos sobre la imagen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.OnTapImage(_:)));
        cell.imgIcono.isUserInteractionEnabled = true;
        cell.imgIcono.tag = indexPath.row;
        cell.imgIcono.addGestureRecognizer(tapGestureRecognizer);
        
        return cell;
    }
}

