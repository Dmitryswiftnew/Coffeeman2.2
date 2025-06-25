
import UIKit
import CoreData
import CoreLocation
import GoogleMaps



class AddCoffeeShopViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, StarRatingViewDelegate {
   
    
    
    let starRatingView = StarRatingView()
    
    // список типов кофе
    
    let coffeeTypes = ["Эспрессо", "Американо", "Капучино", "Латте", "Мокко", "Флэт Уайт"]
    // свойства для UIPickerView и UITextField
    
    var typePicker = UIPickerView()// UIPickerView для выбора типа кофе
    var activeTextField: UITextField?  // Текущее активное текстовое поле для связи с UIPickerView
    
    var coffeeShopToEdit: CoffeeShop?
    
    
    
   
    
    
    // MARK: - Перечисление ячеек
    enum AddPlaceCell: Int, CaseIterable {
        case photo = 0
        case name
        case location
        case type
        case rating
    }
    
    // MARK: - Свойство для хранения данных формы
    
    var selectedImage:  UIImage? // Выбранное фото кофейни
    var name: String? // Название кофейни
    var location: String?  // Адрес
    var type: String? // Тип кофе
    var currentRating: Int = 0 // свойство для хранения рейтинга
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Place" // Заголовок экрана
        
        
        
        // Добавляем кнопки Cancel и Save в навигационную панель
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        
        tableView.keyboardDismissMode = .onDrag // Скрывать клавиатуру при прокрутке
        
        
        // Регистрируем кастомные ячейки для фото и текстовых полей
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationCell")
        
        
        
        // настраиваем UIPickerView
        
        typePicker.dataSource = self
        typePicker.delegate = self
        
 
        if let coffeeShop = coffeeShopToEdit {
            name = coffeeShop.name
            location = coffeeShop.address
            type = coffeeShop.type
            if let data = coffeeShop.photoData {
                selectedImage = UIImage( data: data)
            }
            
            title = "Edit Place"
        }
        
        
        // установка текущего рейтинга
        if let coffeeShop = coffeeShopToEdit {
            currentRating = Int(coffeeShop.rating)
            starRatingView.rating = currentRating
        }
        
        // делегат для обновления рейтинга
        
        starRatingView.delegate = self
        
        
    }

    // метод делегата для starRatingView
    
    func starRatingView(_ starRatingView: StarRatingView, didUpdate rating: Int) {
        // Здесь сохраняем новый рейтинг в локальное свойство контроллера, чтобы потом при сохранении в Core Data записать его
        self.currentRating = rating
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AddPlaceCell.allCases.count // Количество ячеек равно числу элементов enum
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = AddPlaceCell(rawValue: indexPath.row) else {
            // Безопасный выход, если индекс вне диапазона
            return UITableViewCell()
        }
        
        switch cellType {
        case .photo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoTableViewCell
            cell.photoImageView.image = selectedImage ?? UIImage(systemName: "photo")
            return cell
            
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
            cell.textField.placeholder = "Название кофейни"
            cell.textField.text = name
            cell.onTextChanged = { [weak self] text in
                self?.name = text
            }
            return cell
            
        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
            cell.textField.placeholder = "Адрес"
            cell.textField.text = location
            // Если хочешь разрешить ручной ввод, поставь true
            cell.textField.isUserInteractionEnabled = false // ввод адреса только с карты 
            // Удаляем старые цели, чтобы не добавлять несколько раз
            cell.mapButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.mapButton.addTarget(self, action: #selector(openMapSelection), for: .touchUpInside)
            return cell
            
        case .type:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
            cell.textField.placeholder = "Тип кофе"
            cell.textField.text = type
            cell.textField.inputView = typePicker
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(donePressed))
            toolbar.setItems([doneButton], animated: false)
            cell.textField.inputAccessoryView = toolbar
            
            cell.onTextChanged = { [weak self] text in
                self?.type = text
            }
            cell.textField.delegate = self
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
        }
    }


             
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellType = AddPlaceCell(rawValue: indexPath.row) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        switch cellType {
        case .photo:
            showPhotoSourceSelection()
        case .location:
            let mapSelectionVC = MapSelectionViewController()
            mapSelectionVC.delegate = self
            mapSelectionVC.modalPresentationStyle = .fullScreen
            present(mapSelectionVC, animated: true)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
// обработчик кнопки для карты в адресс

@objc func openMapSelection() {
    let mapSelectionVC = MapSelectionViewController()
    mapSelectionVC.delegate = self
    mapSelectionVC.modalPresentationStyle = .fullScreen
    present(mapSelectionVC, animated: true)
    
    
}



    // закрытие пикера для выбора кофе
    
    @objc func donePressed() {
        // получаем выбранную строку в пикере
        
        let selectedRow = typePicker.selectedRow(inComponent: 0)
        // Устанавливаем текст в активное поле и сохраняем выбранный тип
        activeTextField?.text = coffeeTypes[selectedRow]
        type = coffeeTypes[selectedRow]
        
        activeTextField?.resignFirstResponder()
    }
    
    
    
    // Show Photo
    
    func showPhotoSourceSelection() {
        let alert = UIAlertController(title: "Выберите источник фото", message: nil, preferredStyle: .actionSheet)
        
        // проверяем доступность камеры
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
                        self?.presentImagePicker(sourceType: .camera)
                    })
        }
        
        // фото из голереи
        
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default)
                        { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        // отмена
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
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
        
        dismiss(animated: true) // Закрываем экран без сохранения
    }
    
    
    @objc func saveTapped() {
        
        // Проверяем, что все поля заполнены
        guard let name = name, !name.isEmpty,
              let location = location, !location.isEmpty,
              let type = type, !type.isEmpty else {
            showAlert(message: "Пожалуйста, заполните все поля")
            return
        }
        
        let context = PersistenceManager.shared.context
        
        // если редактируем - обновляемб иначе создаем новый объект
        
        let coffeeShop = coffeeShopToEdit ?? CoffeeShop(context: context)
        
        coffeeShop.name = name
        coffeeShop.address = location
        coffeeShop.type = type
        coffeeShop.dateAdded = coffeeShop.dateAdded ?? Date()
        coffeeShop.rating = Int16(currentRating)
        
        
        // Сохраняем фото, если выбрано
        if let image = selectedImage {
            coffeeShop.photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        do {
            try context.save() // Сохраняем в Core Data
            navigationController?.popToRootViewController(animated: true) // Возвращаемся на главный экран
        } catch {
            showAlert(message: "Ошибка сохранения: \(error.localizedDescription)")
        }
        
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert,animated: true)
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
        activeTextField?.text = coffeeTypes[row] //  coffeeTypes — ваш массив с типами кофе
        type = coffeeTypes[row] // сохраняем выбранный тип в переменную
    }
    
    
    
}


extension AddCoffeeShopViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField // Важно: запоминаем активное поле!
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil // Сбрасываем, когда редактирование закончено
        if textField == (tableView.cellForRow(at: IndexPath(row:AddPlaceCell.type.rawValue,section: 0)) as? TextFieldTableViewCell)?.textField {
            if let selectedType = type, let index = coffeeTypes.firstIndex(of: selectedType) {
                typePicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
}


extension AddCoffeeShopViewController: MapSelectionDelegate {

    func didSelectLocation(coordinate: CLLocationCoordinate2D, address: String?) {
        // Обновляем поле адреса и сохраняем координаты
        location = address
        // Например, обновляем UI:
        tableView.reloadRows(at: [IndexPath(row: AddPlaceCell.location.rawValue, section: 0)], with: .automatic)
    }
}
