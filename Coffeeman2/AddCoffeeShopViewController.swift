
import UIKit
import CoreData
import CoreLocation
import MapKit




class AddCoffeeShopViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, StarRatingViewDelegate {
    
    let starRatingView = StarRatingView()
    
    // список типов кофе
    
    let coffeeTypes = ["Espresso", "Americano", "Cappuccino", "Latte", "Mocha", "Flat White", "Macchiato", "Cold Brew", "Iced Coffee", "Tea" ]
    // свойства для UIPickerView и UITextField
    
    var typePicker = UIPickerView()// UIPickerView для выбора типа кофе
    var activeTextField: UITextField?  // Текущее активное текстовое поле для связи с UIPickerView
    
    
    var isCharacteristicsExpanded = false
    var selectedRoastingIndex: Int = 1
    var intensityValue: Float = 0.0
    
    var selectedAcidityLevel: Int = 0
    
    
    
    var coffeeShopToEdit: CoffeeShop?
    
    var selectedTypeIndex: Int?
    
    lazy var pickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Кнопка Cancel слева
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel_button_title", comment: "Кнопка Отмена"), style: .plain, target: self, action: #selector(cancelPicker))
        cancelButton.tintColor = UIColor.brown
        
        // Гибкое пространство между кнопками
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("done_button_title", comment: "Кнопка Готово"), style: .done, target: self, action: #selector(typePickerDonePressed))
        doneButton.tintColor = UIColor.brown
        
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        return toolbar
    }()
    
    
    
    
    // MARK: - Перечисление ячеек
    enum AddPlaceCell: Int, CaseIterable {
        case photo = 0
        case name
        case location
        case type
        case rating
        case expandCharacteristics
    }
    
    // MARK: - Свойство для хранения данных формы
    
    var selectedImage:  UIImage? // Выбранное фото кофейни
    var name: String? // Название кофейни
    var location: String?  // Адрес
    var type: String? // Тип кофе
    var currentRating: Int = 0 // свойство для хранения рейтинга
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.brown
        
        title = coffeeShopToEdit == nil ? "New Place" : "Edit Place"
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        if coffeeShopToEdit != nil {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        tableView.keyboardDismissMode = .onDrag
        
        // Регистрируем кастомные ячейки
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.register(IntensityTableViewCell.self, forCellReuseIdentifier: "IntensityCell")
        tableView.register(AcidityTableViewCell.self, forCellReuseIdentifier: "AcidityCell")
        
        // Настраиваем UIPickerView
        typePicker.dataSource = self
        typePicker.delegate = self
        
        // Загрузка данных из coffeeShopToEdit
        if let coffeeShop = coffeeShopToEdit {
            name = coffeeShop.name
            location = coffeeShop.address
            type = coffeeShop.type
            if let data = coffeeShop.photoData {
                selectedImage = UIImage( data: data)
            }
            
            intensityValue = coffeeShop.intensityLevel
            currentRating = Int(coffeeShop.rating)
            starRatingView.rating = currentRating
            selectedRoastingIndex = Int(coffeeShop.roastingLevel)
            selectedAcidityLevel = Int(coffeeShop.acidityLevel)
        }
        
        // Устанавливаем делегат для starRatingView
        starRatingView.delegate = self
        
        // Обновляем UI таблицы с загруженными данными
        tableView.reloadData()
    }

    
    // метод делегата для starRatingView
    
    func starRatingView(_ starRatingView: StarRatingView, didUpdate rating: Int) {
        // Здесь сохраняем новый рейтинг в локальное свойство контроллера, чтобы потом при сохранении в Core Data записать его
        self.currentRating = rating
    }
    
    // MARK: - Header - Footer section
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (isCharacteristicsExpanded ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return AddPlaceCell.allCases.count
        } else if section == 1 && isCharacteristicsExpanded {
            return 3 // Количество характеристик: обжарка и кислотность
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            // Базовая секция
            guard let cellType = AddPlaceCell(rawValue: indexPath.row) else {
                // Безопасный выход, если индекс вне диапазона
                return UITableViewCell()
            }
            
            switch cellType {
            case .photo:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoTableViewCell
                if let image = selectedImage {
                    cell.photoImageView.image = image
                    cell.photoImageView.tintColor = nil // реал фото без измененния цвета
                } else {
                    let placeholder = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
                    cell.photoImageView.image = placeholder
                    cell.photoImageView.tintColor = UIColor.brown
                }
                return cell
                
            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
                cell.textField.placeholder = "Place name"
                cell.textField.text = name
                cell.textField.isUserInteractionEnabled = true
                cell.showPickerButton(false) // Скрываем кнопку для названия
                cell.onTextChanged = { [weak self] text in
                    cell.textField.delegate = self
                    cell.textField.returnKeyType = .done
                    self?.name = text
                }
                return cell
                
            case .location:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
                cell.textField.text = location
                // Разрешение на ручной ввод
                cell.textField.isUserInteractionEnabled = true // ввод адреса только с карты
                
                // Удаляем старые цели, чтобы не добавлять несколько раз. настройка кнопки пина
                cell.mapButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.mapButton.addTarget(self, action: #selector(openMapSelection), for: .touchUpInside)
                
                // Назначаем делегат для текстового поля
                cell.textField.delegate = self
                cell.textField.returnKeyType = .done
                
                return cell
                
            case .type:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
                cell.textField.placeholder = "Drink type"
                cell.textField.text = type
                cell.textField.isUserInteractionEnabled = true // разрешение на ручной вввод
                cell.showPickerButton(true) // Показываем кнопку для типа
                // Убираем стандартный inputView, чтобы можно было вводить текст вручную
                cell.textField.inputAccessoryView = nil
                cell.textField.inputView = nil
                cell.textField.returnKeyType = .done
                
                
                cell.textField.returnKeyType = .done
                
                // действие на кнопку pickerButton для вызова Picker
                cell.pickerButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.pickerButton.addTarget(self, action: #selector(showTypePicker), for: .touchUpInside)
                
                cell.onTextChanged = { [weak self] text in
                    self?.type = text
                }
                cell.textField.delegate = self
                
                
                if let selectedIndex = selectedTypeIndex {
                    typePicker.selectRow(selectedIndex, inComponent: 0, animated: false)
                }
                
                
                return cell
                
            case .rating:
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                
                if starRatingView.superview == nil {
                    starRatingView.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(starRatingView)
                    NSLayoutConstraint.activate([
                        starRatingView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                        starRatingView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                        starRatingView.heightAnchor.constraint(equalToConstant: 60),
                        starRatingView.widthAnchor.constraint(equalToConstant: 250)
                    ])
                }
                starRatingView.isEditable = true
                return cell
                
            case .expandCharacteristics:
                
                let cell = UITableViewCell(style: .default, reuseIdentifier: "ExpandCell")
                cell.textLabel?.text = isCharacteristicsExpanded ? "Fade characteristics" : "Add characteristics"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.brown
                
                let imageName = isCharacteristicsExpanded ? "chevron.up" : "chevron.down"
                let arrowImage = UIImage(systemName: imageName)
                let arrowImageView = UIImageView(image: arrowImage)
                arrowImageView.tintColor = UIColor.brown
                cell.accessoryView = arrowImageView
                return cell
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "RostingCell")
                cell.textLabel?.text = "Roasting"
                // Создаём Segmented Control
                let roastingControl = UISegmentedControl(items: ["Light", "Medium", "Dark"])
                
                let colors: [UIColor] = [
                    UIColor.brown.withAlphaComponent(0.6),
                    UIColor.brown,
                    UIColor.black
                ]
                
                for index in 0..<roastingControl.numberOfSegments {
                    
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: colors[index]
                    ]
                    roastingControl.setTitleTextAttributes(attributes, for: .normal)
                    
                }
                roastingControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                roastingControl.selectedSegmentTintColor = UIColor.brown
                roastingControl.selectedSegmentIndex = selectedRoastingIndex
                
                
                roastingControl.addTarget(self, action: #selector(roastingChanged(_:)), for: .valueChanged)
                roastingControl.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(roastingControl)
                
                NSLayoutConstraint.activate([
                    roastingControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    roastingControl.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    roastingControl.widthAnchor.constraint(equalToConstant: 200)
                ])
                return cell
                
            } else if indexPath.row == 1 {
                // Новая ячейка с слайдером Intensity
                let cell = tableView.dequeueReusableCell(withIdentifier: "IntensityCell", for: indexPath) as! IntensityTableViewCell
                cell.selectionStyle = .none // выделение ячейки 
                cell.slider.value = intensityValue
                updateSliderColor(slider: cell.slider, value: intensityValue)
                cell.slider.addTarget(self, action: #selector(intensitySliderChanged(_:)), for: .valueChanged)
                return cell
            } else if indexPath.row == 2 {
                // Ячейка для Кислотности
                let cell = tableView.dequeueReusableCell(withIdentifier: "AcidityCell", for: indexPath) as! AcidityTableViewCell
                // Устанавливаем текущее значение кислотности
                cell.acidityLevel = selectedAcidityLevel // Int от 0 до 5
                
                // Обрабатываем изменение значения кислотности
                cell.onAcidityChanged = { [weak self] newLevel in
                    self?.selectedAcidityLevel = newLevel
                    
                    // Обновляем ячейку, чтобы отобразить выбранное состояние
                    
                    let acidityIndexPath = IndexPath(row: 2, section: 1)
                    self?.tableView.reloadRows(at: [acidityIndexPath], with: .none)
                    print("Выбрана кислотность: \(newLevel)")
                }
                
                return cell
            }
        }
            
        return UITableViewCell()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let cellType = AddPlaceCell(rawValue: indexPath.row) else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            
            switch cellType {
            case .photo:
                showPhotoSourceSelection()
            case .location:
                // фокусируемся на текстовом поле
                if let cell = tableView.cellForRow(at: indexPath) as? LocationTableViewCell {
                    cell.textField.becomeFirstResponder()
                }
            case .expandCharacteristics:
                // Обработка раскрытия/сворачивания характеристик, если кнопка в ячейке
                isCharacteristicsExpanded.toggle()
                let characteristicsSectionIndex = 1
                tableView.beginUpdates()
                if isCharacteristicsExpanded {
                    tableView.insertSections(IndexSet(integer: characteristicsSectionIndex), with: .fade)
                } else {
                    tableView.deleteSections(IndexSet(integer: characteristicsSectionIndex), with: .fade)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            default:
                break
            }
            } else if indexPath.section == 1 {
                // Обработка нажатий по характеристикам
                if indexPath.row == 0 {
                // Например, показать UISegmentedControl для обжарки или открыть дополнительный контрол
                    print("Tapped on Степень обжарки")
            } else if indexPath.row == 2 {
                // Обработка кислотности
                           print("Tapped on Кислотность")
            }
        
       
        }
        
        
       
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            guard let cellType = AddPlaceCell(rawValue: indexPath.row) else { return 44 }
            switch cellType {
            case .photo:
                return 216
            case .location, .name, .type:
                return 56
            case .rating, .expandCharacteristics:
                return 44
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                return 100 // для Intensity (слайдера)
            } else if indexPath.row == 2 {
                return 90 // для Acidity (кнопок с заголовком)
            }
            return 44 // для RoastingLevel и других
        }
        return 44
    }    // показ Picker при нажатии на кнопку
    
    @objc func showTypePicker() {
        
        let indexPath = IndexPath(row: AddPlaceCell.type.rawValue, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell else { return }
        
        // Назначаем пикер и панель только для выбора из пикера
        
        cell.textField.inputView = typePicker
        cell.textField.inputAccessoryView = pickerToolbar
        cell.textField.becomeFirstResponder()
    }
    
    // бработчик изменения выбора сегмента для степени обжарки
    
    @objc func roastingChanged(_ sender: UISegmentedControl) {
        selectedRoastingIndex = sender.selectedSegmentIndex
        print("Выбрана степень обжарки: \(sender.titleForSegment(at: selectedRoastingIndex) ?? "")")
           // Здесь можно добавить сохранение в модель, если нужно
    }
    
    
    
    // обработчик кнопки для карты в адресс
    
    @objc func openMapSelection() {
        let mapSelectionVC = MapSelectionViewController()
        mapSelectionVC.delegate = self
        mapSelectionVC.modalPresentationStyle = .fullScreen
        present(mapSelectionVC, animated: true)
        
        
    }
    
    @objc func toggleCharacteristicsSection() {
        isCharacteristicsExpanded.toggle()
        let characteristicsSectionIndex = 1
        
        tableView.beginUpdates()
        
        if isCharacteristicsExpanded {
            tableView.insertSections(IndexSet(integer: characteristicsSectionIndex), with: .fade)
        } else {
            tableView.deleteSections(IndexSet(integer: characteristicsSectionIndex), with: .fade)
        }
        tableView.endUpdates()
    }
    
    
    // закрытие пикера для выбора кофе
    
    @objc func donePressed() {
        // получаем выбранную строку в пикере
        
        let selectedRow = typePicker.selectedRow(inComponent: 0)
        type = coffeeTypes[selectedRow]
        let indexPath = IndexPath(row: AddPlaceCell.type.rawValue, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell {
            cell.textField.text = type
            cell.textField.inputView = nil
            cell.textField.inputAccessoryView = nil
            activeTextField?.resignFirstResponder()
        }
  
    }
    
    
    // изменение цвета слайдера
    
    func updateSliderColor(slider: UISlider, value: Float) {
       // Интерполируем цвет от белого (0) к красному (10)
        let normalized = CGFloat(value / 10.0)
        
        let white = UIColor.white
        let darkBrown = UIColor(red: 0.4, green: 0.1, blue: 0.0, alpha: 1.0)
        
        // Интерполируем компоненты цвета между белым и тёмно-коричневым
        var whiteR: CGFloat = 0, whiteG: CGFloat = 0, whiteB: CGFloat = 0, whiteA: CGFloat = 0
        var darkR: CGFloat = 0, darkG: CGFloat = 0, darkB: CGFloat = 0, darkA: CGFloat = 0
        
        white.getRed(&whiteR, green: &whiteG, blue: &whiteB, alpha: &whiteA)
         darkBrown.getRed(&darkR, green: &darkG, blue: &darkB, alpha: &darkA)
         
         let r = whiteR + (darkR - whiteR) * normalized
         let g = whiteG + (darkG - whiteG) * normalized
         let b = whiteB + (darkB - whiteB) * normalized
        
        let interpolatedColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        slider.minimumTrackTintColor = interpolatedColor
    }
    
    // обработчик изменения слайдера
    
    @objc func intensitySliderChanged(_ sender: UISlider) {
        let steppedValue = round(sender.value) // округляем до целого
        sender.value = steppedValue
        intensityValue = steppedValue
        
        updateSliderColor(slider: sender, value: intensityValue)
    }
    
    
    
    
    // Show Photo
    
    func showPhotoSourceSelection() {
        let alert = UIAlertController(
            title: NSLocalizedString("photo_selection_title", comment: "Заголовок выбора источника фото"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("take_photo", comment: "Кнопка Сделать фото"),
                style: .default) { [weak self] _ in
                    self?.presentImagePicker(sourceType: .camera)
                })
        }
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("choose_from_gallery", comment: "Кнопка Выбрать из Галереи"),
            style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel_button_title", comment: "Кнопка Отмена"),
            style: .cancel))
        
        present(alert, animated: true)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Получаем отредактированное фото, если есть, иначе оригинал
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        tableView.reloadRows(at: [IndexPath(row: AddPlaceCell.photo.rawValue, section: 0)], with: .automatic)
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    // MARK: - Actions
    
    @objc func cancelTapped() {
        
        dismiss(animated: true, completion: nil) // Закрываем экран без сохранения
    }
    
    
    @objc func saveTapped() {
        guard let name = name, !name.isEmpty,
              let location = location, !location.isEmpty,
              let type = type, !type.isEmpty else {
            showAlert(message: "Пожалуйста, заполните все поля")
            return
        }
        
        let context = PersistenceManager.shared.context
        let coffeeShop = coffeeShopToEdit ?? CoffeeShop(context: context)
        
        coffeeShop.name = name
        coffeeShop.address = location
        coffeeShop.type = type
        coffeeShop.dateAdded = coffeeShop.dateAdded ?? Date()
        coffeeShop.rating = Int16(currentRating)
        
        if let image = selectedImage {
            coffeeShop.photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        // ВАЖНО: Присваиваем значения второй секции до сохранения
        coffeeShop.roastingLevel = Int16(selectedRoastingIndex)
        coffeeShop.intensityLevel = intensityValue
        coffeeShop.acidityLevel = Int16(selectedAcidityLevel)
        
        do {
            try context.save()
            
            // Закрываем экран после успешного сохранения
            if navigationController?.viewControllers.first == self {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
            
        } catch {
            showAlert(message: "Ошибка сохранения: \(error.localizedDescription)")
        }
        
        
    }

   
    
    func showAlert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("error_title", comment: "Заголовок алерта ошибки"),
            message: NSLocalizedString("fill_all_fields_message", comment: "Сообщение о необходимости заполнить все поля"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok_button_title", comment: "Кнопка OK"), style: .default))
        present(alert, animated: true)
    }
    
    
    @objc func typePickerDonePressed() {
      let selectedRow = selectedTypeIndex ?? typePicker.selectedRow(inComponent: 0)
        selectedTypeIndex = selectedRow
        
        type = coffeeTypes[selectedRow]
        
        // Обновляем текстовое поле с типом напитка
        let indexPath = IndexPath(row: AddPlaceCell.type.rawValue, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell {
            cell.textField.text = type
            // Сбрасываем inputView, чтобы при следующем вводе показывалась клавиатура
            cell.textField.inputView = nil
            cell.textField.inputAccessoryView = nil
            cell.textField.resignFirstResponder()

        }
    }
    
    
    @objc func cancelPicker() {
        activeTextField?.resignFirstResponder()
    }
    
    
    
}




// MARK: - Расширение для UIPickerView

extension AddCoffeeShopViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coffeeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coffeeTypes[row]
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTypeIndex = row
        
        
    }
    
    
    
}


extension AddCoffeeShopViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField // Важно: запоминаем активное поле!

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil // Сбрасываем, когда редактирование закончено
        // Определяем, какое поле редактировалось
        guard let indexPath = tableView.indexPathForRow(at: textField.convert(textField.bounds.origin, to: tableView)),
              let cellType = AddPlaceCell(rawValue: indexPath.row) else { return }
        
        switch cellType {
        case .name:
            name = textField.text
        case .location:
            location = textField.text
        case .type:
            type = textField.text
            selectedTypeIndex = nil
        default:
            break
        }
        
    }
    
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // скрыть клаву
        
        // сохранить введенный текст в соответствующую переменную
        
        guard let indexPath = tableView.indexPathForRow(at: textField.convert(textField.bounds.origin, to: tableView)),
              let cellType = AddPlaceCell(rawValue: indexPath.row) else {
            return true
        }
              
        switch cellType {
        case .name:
            name = textField.text
        case .location:
            location = textField.text
        case .type:
            type = textField.text
        default:
            break
        }
        
        return true
        
    }
    
    
    
}


extension AddCoffeeShopViewController: MapSelectionDelegate {
    
    func didSelectLocation(coordinate: CLLocationCoordinate2D, address: String?) {
        // Обновляем поле адреса и сохраняем координаты
        location = address
        // обновляем UI:
        tableView.reloadRows(at: [IndexPath(row: AddPlaceCell.location.rawValue, section: 0)], with: .automatic)
    }
}
