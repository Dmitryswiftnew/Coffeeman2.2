import UIKit

class AcidityTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Acidity"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    
    
    
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private let maxLevel = 5
    
    // Значение кислотности от 0 до 5
    var acidityLevel: Int = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    // Коллбек для передачи выбранного значения наружу
    var onAcidityChanged: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupStackView()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    private func setupStackView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        
        
        
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        titleLabel.textAlignment = .center
    }
    
    private func setupButtons() {
        for i in 1...maxLevel {
            let button = UIButton(type: .custom)
            
            // Устанавливаем картинки для состояния normal и selected
            // Замените "emptyImage" и "filledImage" на имена ваших картинок в проекте
            let emptyImage = UIImage(named: "coffeeEmpty")?.withRenderingMode(.alwaysTemplate)
            let filledImage = UIImage(named: "coffeeFull")?.withRenderingMode(.alwaysTemplate)
            
            button.setImage(emptyImage, for: .normal)
            button.setImage(filledImage, for: .selected)
            
            button.tintColor = UIColor.brown
            
            // Ограничиваем размер кнопки, чтобы не растягивалась
            
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 36),
                button.heightAnchor.constraint(equalToConstant: 36)
                
            ])
            
            button.tag = i // для определения номера кнопки
            
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let selectedLevel = sender.tag
        
        acidityLevel = (selectedLevel == acidityLevel) ? 0 : selectedLevel
        
        onAcidityChanged?(acidityLevel)
    }
    
    private func updateButtonSelectionStates() {
        for button in buttons {
            button.isSelected = button.tag <= acidityLevel
        }
    }
}

