
import Foundation
import UIKit
import CoreData

protocol StarRatingViewDelegate: AnyObject {
    func starRatingView(_ starRatingView: StarRatingView, didUpdate rating: Int)
}

class StarRatingView: UIView {
    
    var isEditable: Bool = true {
        didSet {
            updateUserInteraction()
        }
    }
    
    // Массив UIImageView для звезд
    
    private var starImageViews: [UIImageView] = []
    
    
    // макс. кол. звезд
    
    private let maxStars = 5
    
    // текущий рейтинг (0...5)
    
    var rating: Int = 0 {
        didSet {
            updateStars()
            
        }
    }
    
    // делегат для уведомления об изменени рейтинга
    weak var delegate: StarRatingViewDelegate?
    
   
    
    // Инициализаторы
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    // Создаём UIImageView для каждой звезды и добавляем их в стек
    private func setupStars() {
        // Создаём UIStackView для удобного расположения звёзд
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        // Задаём констрейнты для stack, чтобы он занимал всю площадь StarRatingView
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Создаём звёзды
        for i in 0..<maxStars {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemYellow
            
            // Убираем жёсткие размеры и даём возможность звёздам подстраиваться под размер stackView
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // При необходимости можно задать минимальный и максимальный размер, например:
            // imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
            // imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
            
            imageView.image = UIImage(systemName: "star") // пустая звезда
            imageView.isUserInteractionEnabled = true
            imageView.tag = i + 1 // tag = 1 для первой звезды, 2 для второй и т.д.
            stack.addArrangedSubview(imageView)
            starImageViews.append(imageView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleStarTap(_:)))
            imageView.addGestureRecognizer(tap)
        }
        
        updateUserInteraction()
        updateStars()
    }

    
   

    private func updateUserInteraction() {
        for star in starImageViews {
            star.isUserInteractionEnabled = isEditable
        }
    }
    

    
    
    
    
    // Обновляем отображение звёзд в зависимости от рейтинга
    
    private func updateStars() {
        for (index, imageView) in starImageViews.enumerated() {
            if index < rating {
                imageView.image = UIImage(systemName: "star.fill")
            } else {
                imageView.image = UIImage(systemName: "star")
            }
        }
        
    }
    
    
    // Обработка нажатия на звезду
    
    @objc private func handleStarTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedStar = gesture.view as? UIImageView else { return }
        let tappedValue = tappedStar.tag // tag = 1...5
        
        if rating == tappedValue {
            rating = 0 // повторное нажатие сбрасывает рейтинг
        } else {
            // Иначе устанавливаем рейтинг по индексу
            rating = tappedValue
        }
       
        
        // // Уведомляем делегата
        delegate?.starRatingView(self, didUpdate: rating)
        
    }
    
    
    
}
