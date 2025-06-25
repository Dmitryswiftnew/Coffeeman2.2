
import Foundation
import UIKit
import CoreData


class LocationTableViewCell: UITableViewCell {
    let textField = UITextField()
    let mapButton = UIButton(type: .system)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        mapButton.tintColor = .systemBrown
        
        contentView.addSubview(textField)
        contentView.addSubview(mapButton)
        
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
               textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
               textField.trailingAnchor.constraint(equalTo: mapButton.leadingAnchor, constant: -8),
               
               mapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
               mapButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
               mapButton.widthAnchor.constraint(equalToConstant: 28),
               mapButton.heightAnchor.constraint(equalToConstant: 28)
                                               
            
        ])
        
        
    }
    
    
}
