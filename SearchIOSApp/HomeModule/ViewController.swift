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
    @IBOutlet weak var searchBar: UISearchBar!
    var viewModel: VCViewModel!
    let disposeBag = DisposeBag()
    
    var activityIndivator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    private func setupView() {
        
        setupNavBar()
        configureTableView()
        setupSearchBar()
        
    }
    
    private func setupNavBar() {
        navigationItem.title = "Search Github Profiles"
        activityIndivator = UIActivityIndicatorView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndivator)
    }
    
    private func configureTableView() {
        tableView.refreshControl = UIRefreshControl()
        tableView.delegate = self
        bindTableView()
    }
    
    private func bindTableView() {
        tableView.refreshControl?.rx.controlEvent(.valueChanged).subscribe(onNext: {[weak self] _ in
            if self?.tableView.refreshControl?.isRefreshing ?? false {
                self?.viewModel.pullToRefresh()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }).disposed(by: disposeBag)
        
        viewModel.cellModelObservalble
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, cellVM: CellViewModel) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: IndexPath(row: index, section: 0)) as? UserCell else { return UITableViewCell()}
                cell.configure(viewModel: cellVM)
                return cell
            }.disposed(by: disposeBag)
    }
    
    private func setupSearchBar() {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] searchString in
                guard let self = self else {return}
                self.viewModel.searchString = searchString
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel(){
        viewModel.loaderSubject.bind(to: activityIndivator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        
        viewModel.errorSubject.subscribe(onNext: {[weak self] error in
            guard let self = self else {return}
            
            let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alertController, animated: true)
        }).disposed(by: disposeBag)
        
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

