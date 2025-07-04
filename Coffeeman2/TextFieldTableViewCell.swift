

import Foundation
import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let pickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .brown
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onTextChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        
        NSLayoutConstraint.activate([
            pickerButton.widthAnchor.constraint(equalToConstant: 18),
            pickerButton.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func showPickerButton(_ show: Bool) {
        textField.rightView = show ? pickerButton : nil
        textField.rightViewMode = show ? .always : .never
    }
    
    @objc func textFieldDidChange() {
        onTextChanged?(textField.text ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

