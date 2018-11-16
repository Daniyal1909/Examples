//
//  BaseTableView.swift
//  MyTester
//
//  Created by Деветов Даниял on 11/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit

protocol BaseTVCDelegate {
    func didSelect(type: BaseTVCType, item: BaseCellModel)
}

enum BaseTVCType {
    case menu
    case settings
    case deviceModel
    case typeOfUseDevice
    case messageSubject
}

protocol BaseTViewProtocol: BaseViewProtocol {
    func showLoading()
    func hideLoading()
    func setResults(items: [BaseCellModel])
}

class BaseTVC: UIViewController {
    
    @IBOutlet weak var listEmptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var items: [BaseCellModel] = []
    var delegate: BaseTVCDelegate?
    var type: BaseTVCType = .menu
    var presenter: BaseTVCPresenterProtocol!
    var selectedItemID: Int?
    
    var cellNibName = ""
    var cellReuseIdentifier = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = BaseTVCPresenter(view: self, type: type)
        if items.isEmpty {
            presenter.getItems()
        }
        switch type {
        case .typeOfUseDevice:
            self.title = "Использование"
            cellNibName = "BaseCellWithOutImage"
            cellReuseIdentifier = "withOutImage"
        case .deviceModel:
            self.title = "Модель"
            cellNibName = "BaseCellWithOutImage"
            cellReuseIdentifier = "withOutImage"
        case .settings:
            self.title = Localizer.shared.stringForKey(key: "settings")
            cellNibName = "BaseCellWithTwoLabels"
            cellReuseIdentifier = "withTwoLabels"
        case  .messageSubject:
            self.title = Localizer.shared.stringForKey(key: "subject")
            cellNibName = "BaseCellWithOutImage"
            cellReuseIdentifier = "withOutImage"
        default:
            cellNibName = "BaseCellWithImage"
            cellReuseIdentifier = "withImage"
        }
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: cellNibName, bundle: Bundle.main), forCellReuseIdentifier: cellReuseIdentifier)
    }
}

extension BaseTVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? BaseCell else { return UITableViewCell() }
        let item = items[indexPath.row]
        cell.setConfigurations(with: item)
        cell.setRightImageChecked(item.id == selectedItemID)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(44 + items[indexPath.row].bottomSpace + items[indexPath.row].topSpace)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(type: type, item: items[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

extension BaseTVC: BaseTViewProtocol {
    func showLoading() {
        loadingIndicator.show()
        tableView.isHidden = true
    }
    
    func hideLoading() {
        loadingIndicator.hide()
        tableView.isHidden = false
    }
    
    func showListEmptyLabel() {
        listEmptyLabel.isHidden = false
        tableView.isHidden = true
        loadingIndicator.hide()
    }
    
    func setResults(items: [BaseCellModel]) {
        self.items = items
        tableView.reloadData()
    }
}
