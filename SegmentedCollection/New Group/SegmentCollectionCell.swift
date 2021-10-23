//
//  SegmentCollectionCell.swift
//  SegmentedCollection
//
//  Created by Trabajo on 27/09/21.
//

import UIKit

class SegmentCollectionCell: UICollectionViewCell {

    @IBOutlet var segmentTitle: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var selectedBackground: SegmentSelectedBackground!
    var segmentBackground:UIColor? = nil{
        didSet{
            if self.segmentBackground != oldValue{
                setTitleColor()
            }
        }
    }
    var segmentTint:UIColor? = nil{
        didSet{
            if self.segmentTint != oldValue{
                self.selectedBackground.backgroundShape.fillColor = segmentTint?.cgColor
                setTitleColor()
            }
        }
    }
    var isLocked:Bool = false{
        didSet{
            self.imageView.isHidden = !isLocked
            self.imageView.image = isLocked ? UIImage(systemName: "lock.fill"):nil
        }
    }
    
//    var includeSeparator:Bool = false{
//        didSet{
//            self.separatorView.isHidden = !includeSeparator
//        }
//    }
    
    override var isSelected: Bool{
        didSet{
            checkSelected()
            setTitleColor()
        }
    }
    
    func checkSelected(){
        self.selectedBackground.isHidden = !self.isSelected
    }
    private func setTitleColor(){
        let textColor:UIColor? = self.isSelected ? self.segmentBackground:self.segmentTint
        self.segmentTitle.textColor = textColor
        self.imageView.tintColor = textColor
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//
//    }

}
