//
//  MainTableViewCell.swift
//  market
//
//  Created by Cesar Julián Azuero Garavito on 9/23/19.
//  Copyright © 2019 Prueba. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell
{
    @IBOutlet weak var imgIcono: UIImageView!
    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtPrecio: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
