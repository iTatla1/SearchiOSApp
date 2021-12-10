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
        tableView.delegate = self
        tableView.dataSource = self
        setupSearchBar()
    }
    
    private func setupSearchBar() {
       let searchBar = UISearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func bindViewModel(){
        viewModel.bindClosure = { output in
            switch output {
            case .refreshData:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                   
                
            case .showError(_):
                break
            case .showProgress(_):
                break
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {return}
        viewModel.searchString = searchText
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UserCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {return}
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
            viewModel.nextPage()
        }
    }
}

