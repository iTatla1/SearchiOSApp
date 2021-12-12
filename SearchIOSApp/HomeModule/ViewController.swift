//
//  ViewController.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: VCViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
    }

    private func setupView() {
        bindTableView()
        setupSearchBar()
        tableView.delegate = self
    }
    
    private func bindTableView() {
        viewModel.cellModelObservalble
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, cellVM: CellViewModel) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: IndexPath(row: index, section: 0)) as? UserCell else { return UITableViewCell()}
                cell.configure(viewModel: cellVM)
                return cell
            }.disposed(by: disposeBag)
        
        
    }
    
    private func setupSearchBar() {
       let searchBar = UISearchBar()
        searchBar.rx.text.orEmpty
            .filter{!$0.isEmpty}
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] searchString in
                guard let self = self else {return}
                self.viewModel.searchString = searchString
            })
            .disposed(by: disposeBag)
        navigationItem.titleView = searchBar
    }
    
    private func bindViewModel(){
        viewModel.loaderSubject
            .subscribe(onNext: {[weak self] isLoading in
                guard let self = self else {return}
                print("Is Loading \(isLoading)")
            })
            .disposed(by: disposeBag)
        
        viewModel.errorSubject.subscribe(onNext: {[weak self] error in
            guard let self = self else {return}
            print("Error: \(error)")
        })
        .disposed(by: disposeBag)

    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {return}
        viewModel.searchString = searchText
    }
}


extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {return}
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
            viewModel.nextPage()
        }
    }
}

