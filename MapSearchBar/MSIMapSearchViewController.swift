//
//  MSIMapSearchViewController.swift
//  MicroStrategyMobile
//
//  Created by Zhang, Hongchao on 12/5/16.
//  Copyright © 2016 MicroStratgy Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public enum LayerDataShownType {
    case showPart
    case showAll
}

protocol MSIMapSearchViewControllerDelegate: class {
    func getAllAnnotationsInMap() -> [String: [CustomAnnotation]]
    func getLayerNames() -> [String]
    func highlightAnnotations(annotations: [String: [CustomAnnotation]])
}

class MSIMapSearchViewController: UIViewController {
    var maxFrame: CGRect!
    weak var delegate: MSIMapSearchViewControllerDelegate?
    weak var mapView: MKMapView?
    var searchView: MSIMapSearchView?
    var localSearch: MKLocalSearch?
    var dataFromDataset: [String: [CustomAnnotation]]?
    var dataFromAppleService: [MKMapItem]?
    var allFilteredLayerNames: [String]?
    var allFilteredLayerDataShownType: [LayerDataShownType]?
    
    init(maxFrame: CGRect, delegate: MSIMapSearchViewControllerDelegate?, mapView: MKMapView) {
        super.init(nibName: nil, bundle: nil)
        self.addKeyboardObservers()
        self.maxFrame = maxFrame
        self.delegate = delegate
        self.mapView = mapView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if self.localSearch != nil {
            self.localSearch!.cancel()
            self.localSearch = nil
        }
        self.removeObservers()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.mockDataForTableView()
        
        self.searchView = self.createSearchView()
        self.searchView?.setSearchView(to: .beforeBegining)
        
        self.view = self.searchView
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MSIMapSearchViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MSIMapSearchViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        // Do something here
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let searchBar = self.searchView?.searchBar {
            for subview in searchBar.subviews[0].subviews {
                if let subview = subview as? UIButton {
                    self.perform(#selector(MSIMapSearchViewController.enable(_:)), with: subview, afterDelay: 0.1)
                }
            }
        }
    }
    
    @objc func enable(_ cancelButton: UIButton) {
        cancelButton.isEnabled = true
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func mockDataForTableView() {
        self.dataFromDataset = self.delegate?.getAllAnnotationsInMap()
        self.allFilteredLayerNames = self.delegate?.getLayerNames()
        self.allFilteredLayerDataShownType = [LayerDataShownType]()
        if let layerNames = self.allFilteredLayerNames {
            if layerNames.count > 1 {
                for _ in 0..<layerNames.count {
                    self.allFilteredLayerDataShownType?.append(.showPart)
                }
            } else if layerNames.count == 1 {
                self.allFilteredLayerDataShownType?.append(.showAll)
            }
        }
    }
    
    private func createSearchView() -> MSIMapSearchView? {
        let lSearchView = MSIMapSearchView(frame: self.maxFrame)
        
        lSearchView.createInitView()
        lSearchView.setSearchBarDelegate(delegate: self)
        lSearchView.setTableViewDelegate(delegate: self)
        lSearchView.setTableViewDataSource(dataSource: self)
        
        return lSearchView
    }
    
    public func filterAnnotations(for keyword: String?) {
        guard let keyword = keyword else {
            return
        }
        
        var allFilteredAnnotations = [String: [CustomAnnotation]]()
        var allFilteredLayerNames = [String]()
        var allLayerDataShownType = [LayerDataShownType]()
        var totalCount = 0
        if let allLayerNames = delegate?.getLayerNames(), let allAnnotations = delegate?.getAllAnnotationsInMap() {
            for index in 0..<allLayerNames.count {
                let layerName = allLayerNames[index]
                if let allAnnotationsInLayer = allAnnotations[layerName] {
                    var filteredAnnotationsInLayer: [CustomAnnotation] = [CustomAnnotation]()
                    for annotation in allAnnotationsInLayer {
                        let annotationName = annotation.getAnnotationDisplayName()
                        if (annotationName?.lowercased().range(of: keyword.lowercased())) != nil {
                            filteredAnnotationsInLayer.append(annotation)
                        }
                    }
                    if filteredAnnotationsInLayer.count > 0 {
                        allFilteredLayerNames.append(layerName)
                        allFilteredAnnotations[layerName] = filteredAnnotationsInLayer
                        allLayerDataShownType.append(.showPart)
                        totalCount += filteredAnnotationsInLayer.count
                    }
                }
            }
            
            self.dataFromDataset = allFilteredAnnotations
            self.allFilteredLayerNames = allFilteredLayerNames
            self.allFilteredLayerDataShownType = allLayerDataShownType
        }
        
        if self.searchView?.searchType == .local {
            self.searchView?.updateTableView()
        }
        self.searchView?.updateSearchTypeControl(index: 0, count: totalCount)
        
        if totalCount > 0 {
            self.searchView?.setSearchView(to: .endSearchingWithResults)
        }
        
        delegate?.highlightAnnotations(annotations: allFilteredAnnotations)
    }
    
    public func searchFromAppleService(for keyword: String?) {
        func checkLocalDatasetResult() {
            if let dataFromDataset = self.dataFromDataset {
                if dataFromDataset.count == 0 {
                    self.searchView?.setSearchView(to: .endSearchingWithoutResults)
                }
            } else {
                self.searchView?.setSearchView(to: .endSearchingWithoutResults)
            }
        }
        
        guard let mapView = self.mapView else {
            return
        }
        
        if self.localSearch != nil {
            self.localSearch!.cancel()
            self.localSearch = nil
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region = mapView.region
        
        self.localSearch = MKLocalSearch(request: request)
        self.localSearch?.start(completionHandler: {(response, error) in
            guard let response = response else {
                if let error = error {
                    print("Search error: \(error)")
                }
                self.searchView?.updateSearchTypeControl(index: 1, count: 0)
                checkLocalDatasetResult()
                return
            }
            
            if let dataFromDataset = self.dataFromDataset {
                if dataFromDataset.count == 0 {
                    self.searchView?.setSearchView(to: .endSearchingWithResults)
                }
            }
            
            self.dataFromAppleService = response.mapItems
            if self.searchView?.searchType == .appleService {
                self.searchView?.updateTableView()
            }
            var totalCount = 0
            if let dataFromAppleService = self.dataFromAppleService {
                totalCount = dataFromAppleService.count
            }
            self.searchView?.updateSearchTypeControl(index: 1, count: totalCount)
            
            for item in response.mapItems {
                print("\(item)")
            }
        })
    }
    
    override public func loadView() {
        self.view = UIView(frame: self.maxFrame)
    }
    
    func getRows(for section: Int) -> [CustomAnnotation]? {
        guard let layerNames = self.allFilteredLayerNames else {
            return nil
        }
        
        guard section < layerNames.count else {
            return nil
        }
        
        let layerName = layerNames[section]
        return self.dataFromDataset?[layerName]
    }
    
}

extension MSIMapSearchViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            return
        }
        
        self.searchFromAppleService(for: searchText)
        self.filterAnnotations(for: searchText)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NSLog("Cancel button is clicked")
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.searchView?.setSearchView(to: .beforeBegining)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NSLog("Search button is clicked")
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin editing")
        searchBar.showsCancelButton = true
        self.searchView?.setSearchView(to: .beginToSearch)
    }
}

extension MSIMapSearchViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MSIMapSearchTableCellView? = tableView.dequeueReusableCell(withIdentifier: SearchViewUIConstants.TableView.cellReuseIdentifier) as? MSIMapSearchTableCellView
        if cell == nil {
            cell = MSIMapSearchTableCellView(style: UITableViewCell.CellStyle.default, reuseIdentifier: SearchViewUIConstants.TableView.cellReuseIdentifier)
        }
        var cellText = "--"
        if let searchView = self.searchView {
            switch searchView.searchType {
            case .local:
                let section = indexPath[0]
                let row = indexPath[1]
                guard let annotations = self.getRows(for: section) else {
                    break
                }
                cellText = annotations[row].getAnnotationDisplayName()!
            case .appleService:
                if let dataFromAppleService = self.dataFromAppleService {
                    let mapItem = dataFromAppleService[indexPath[1]]
                    if let name = mapItem.name {
                        cellText = name
                    }
                }
            }
            cell?.createLabels(searchType: searchView.searchType, contentString: cellText)
        }
        
        return cell!
    }
}

extension MSIMapSearchViewController: UITableViewDelegate {
    
    private func getRemainningCount(for section: Int) -> Int {
        guard let layerNames = self.allFilteredLayerNames else {
            return 0
        }
        
        guard section < layerNames.count else {
            return 0
        }
        
        var remainningCount = 0
        
        if let annotations = self.dataFromDataset?[layerNames[section]] {
            if let layerDataShownType = self.allFilteredLayerDataShownType?[section] {
                switch layerDataShownType {
                case .showPart:
                    remainningCount = annotations.count - SearchViewUIConstants.TableView.defaultDisplayCount
                    remainningCount = remainningCount > -1 ? remainningCount : 0
                case .showAll:
                    remainningCount = 0
                }
            }
        }
        
        return remainningCount
    }
    
    private func getFooterText(for section: Int) -> String {
        var footerText = ""
        if let layerDataShownType = self.allFilteredLayerDataShownType?[section] {
            switch layerDataShownType {
            case .showPart:
                let remainningCount = self.getRemainningCount(for: section)
                footerText = "+\(remainningCount) more"
            case .showAll:
                footerText = "Hide"
            }
        }
        
        return footerText
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        if let searchType = self.searchView?.searchType {
            switch searchType {
            case .local:
                guard let layerNames = self.allFilteredLayerNames else {
                    break
                }
                sectionCount = layerNames.count
            case .appleService:
                sectionCount = 1
            }
        }
        
        return sectionCount
        
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.searchView?.searchType == .local, let allFilteredLayerNames = self.allFilteredLayerNames {
            if allFilteredLayerNames.count > 1 {
                let headerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: SearchViewUIConstants.TableView.sectionHeaderHeight))
                let header = MSIMapSearchTableViewHeader(frame: headerFrame, text: allFilteredLayerNames[section])
                return header
            } else if allFilteredLayerNames.count == 1 {
                let headerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: SearchViewUIConstants.TableView.sectionSpace))
                let header = MSIMapSearchTableViewHeader(frame: headerFrame, text: nil)
                return header
            }
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.searchView?.searchType == .local {
            let footerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: SearchViewUIConstants.TableView.sectionFooterHeight))
            let footer = MSIMapSearchTableViewFooter(frame: footerFrame, section: section, delegate: self)
            footer.createButton(text: self.getFooterText(for: section))
            
            return footer
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.searchView?.searchType == .local, let allFilteredLayerNames = self.allFilteredLayerNames {
            if allFilteredLayerNames.count > 1 {
                return SearchViewUIConstants.TableView.sectionHeaderHeight
            } else if allFilteredLayerNames.count == 1 {
                return SearchViewUIConstants.TableView.sectionSpace
            }
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.searchView?.searchType == .local {
            return SearchViewUIConstants.TableView.sectionFooterHeight
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let searchView = self.searchView {
            switch searchView.searchType {
            case .local:
                if let annotations = self.getRows(for: section) {
                    if let layerDataShownType = self.allFilteredLayerDataShownType?[section] {
                        switch layerDataShownType {
                        case .showPart:
                            let actualRowsCount = annotations.count
                            rows = actualRowsCount > SearchViewUIConstants.TableView.defaultDisplayCount ? SearchViewUIConstants.TableView.defaultDisplayCount : actualRowsCount
                        case .showAll:
                            rows = annotations.count
                        }
                    } else {
                        rows = annotations.count
                    }
                }
            case .appleService:
                if let count = self.dataFromAppleService?.count {
                    rows = count
                }
            }
        }
        return rows
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchViewUIConstants.TableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MSIMapSearchTableCellView {
            cell.highlightCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MSIMapSearchTableCellView {
            cell.dehighlightCell()
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchView?.searchBar?.resignFirstResponder()
        print("swipe the table view")
    }
}

extension MSIMapSearchViewController: MSIMapSearchTableViewFooterDelegate {
    func showTypeChange(for section: Int) {
        if let layerDataShownType = self.allFilteredLayerDataShownType?[section] {
            switch layerDataShownType {
            case .showPart:
                self.allFilteredLayerDataShownType?[section] = .showAll
            case .showAll:
                self.allFilteredLayerDataShownType?[section] = .showPart
            }
        }
        
        self.searchView?.updateTableView()
    }
}
