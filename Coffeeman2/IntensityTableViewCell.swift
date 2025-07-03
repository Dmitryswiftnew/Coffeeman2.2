

import Foundation
import UIKit
import CoreData


class IntensityTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Intensity"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.isContinuous = true
        return slider
    }()
    
    
    // StackView
    
    let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(slider)
        contentView.addSubview(labelsStackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
           
            labelsStackView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 4),
            labelsStackView.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -8),
            labelsStackView.heightAnchor.constraint(equalToConstant: 20)
            
        ])
        
        
        // метки от 0 до 10
        
        for i in 0...10 {
            let label = UILabel()
            label.text = "\(i)"
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            labelsStackView.addArrangedSubview(label)
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
