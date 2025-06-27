
import Foundation
import UIKit
import CoreData


class LocationTableViewCell: UITableViewCell {
    let textField = UITextField()
    let mapButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        mapButton.setImage(UIImage(systemName: "mappin.circle.fill"), for: .normal)
        mapButton.tintColor = .brown
        mapButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        textField.placeholder = "Адрес"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rightView = mapButton
        textField.rightViewMode = .always
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}


