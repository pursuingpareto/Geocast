//
//  EpisodeCell.swift
//  Geocast
//
//  Created by Debarshi Chaudhuri on 11/11/15.
//  Copyright © 2015 Andrew Brown. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var episodeTitle: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var publicationDate: UILabel!
        
    @IBOutlet weak var progressBar: UIProgressView!
}