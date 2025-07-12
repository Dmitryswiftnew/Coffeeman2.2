
import Foundation
import UIKit
import CoreData

class CoffeeShopTableViewCell: UITableViewCell {
    
    
    let starRatingView = StarRatingView()
    
    
    // UIImageView для фото кофейни
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8 // скругление углов
        imageView.backgroundColor = UIColor.systemGray5 // фон для дефолтного состояния
        return imageView
        
    }()
    
    // UILabel для типа кофе
    
    let typeLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.darkGray
        return label
        
    }()
    
    
    
    // UILabel название кофейни
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.label
        return label
        
    }()
    
    
    // UILabel для адреса
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.gray
        label.numberOfLines = 2 // адрес может быть в 2 строки
        return label
    }()
    
    
    // UILabel для иконки информации (Unicode символ ⓘ)
    
    let infoIconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\u{24D8}" // Unicode для ⓘ
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.brown
        label.textAlignment = .center
        return label
    }()
    


    private let nameAndRatingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    
    
    // Инициализатор ячейки
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews() // вызываем настройку UI
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Настройка UI элементов и Auto Layout
    
    private func setupViews() {
        
        
        contentView.addSubview(photoImageView)
        contentView.addSubview(infoIconLabel)
        contentView.addSubview(nameAndRatingStack)
        contentView.addSubview(typeLabel)
        contentView.addSubview(addressLabel)
            
            nameAndRatingStack.addArrangedSubview(nameLabel)
            nameAndRatingStack.addArrangedSubview(starRatingView)
            
            starRatingView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                starRatingView.heightAnchor.constraint(equalToConstant: 20),
                starRatingView.widthAnchor.constraint(equalToConstant: 100)
            ])
        
        NSLayoutConstraint.activate([
                photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                photoImageView.widthAnchor.constraint(equalToConstant: 60),
                photoImageView.heightAnchor.constraint(equalToConstant: 60),
                
                infoIconLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                infoIconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                infoIconLabel.widthAnchor.constraint(equalToConstant: 24),
                infoIconLabel.heightAnchor.constraint(equalToConstant: 24),
                
                nameAndRatingStack.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
                nameAndRatingStack.trailingAnchor.constraint(equalTo: infoIconLabel.leadingAnchor, constant: -12),
                nameAndRatingStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                
                typeLabel.topAnchor.constraint(equalTo: nameAndRatingStack.bottomAnchor, constant: 4),
                typeLabel.leadingAnchor.constraint(equalTo: nameAndRatingStack.leadingAnchor),
                typeLabel.trailingAnchor.constraint(equalTo: nameAndRatingStack.trailingAnchor),
                
                addressLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
                addressLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
                addressLabel.trailingAnchor.constraint(equalTo: typeLabel.trailingAnchor),
                addressLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
            
        ])
        
    }
    
    // Метод для настройки содержимого ячейки из объекта CoffeeShop
    func configure(with coffeeShop: CoffeeShop) {
        // Если есть фото — показываем его, иначе дефолтное изображение
        if let data = coffeeShop.photoData, let image = UIImage(data: data) {
            photoImageView.image = image
        } else {
            let placeholder = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
            photoImageView.image = placeholder
            photoImageView.tintColor = UIColor.brown
            
        }
        
        nameLabel.text = coffeeShop.name ?? "Без названия"
        typeLabel.text = coffeeShop.type?.isEmpty == false ? coffeeShop.type : "Тип не указан"
        addressLabel.text = coffeeShop.address?.isEmpty == false ? coffeeShop.address : "Адрес не указан"
        starRatingView.rating = Int(coffeeShop.rating) // rating — свойство Core Data (Int16 или Int)
        starRatingView.isEditable = false
    }
    
}
