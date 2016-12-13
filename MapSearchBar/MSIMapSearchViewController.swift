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
    func getAllAnnotationsInMap() -> [String: [MSIMWAnnotation]]
    func getLayerNames() -> [String]
    func highlightAnnotations(annotations: [String: [MSIMWAnnotation]])
}

class MSIMapSearchViewController: UIViewController {
    var maxFrame: CGRect
    weak var delegate: MSIMapSearchViewControllerDelegate?
    weak var mapView: MKMapView?
    var searchView: MSIMapSearchView?
    var localSearch: MKLocalSearch?
    var dataFromDataset: [String: [MSIMWAnnotation]]?
    var dataFromAppleService: [MKMapItem]?
    var allFilteredLayerNames: [String]?
    var allFilteredLayerDataShownType: [LayerDataShownType]?

    init(theMaxFrame: CGRect, theDelegate: MSIMapSearchViewControllerDelegate?, theMapView: MKMapView) {
        maxFrame = theMaxFrame
        delegate = theDelegate
        mapView = theMapView
        super.init(nibName: nil, bundle: nil)
        self.addObservers()
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
        self.searchView?.setSearchViewState(to: .beforeBegining)

        self.view = self.searchView
//        self.view.addSubview(self.searchView!)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MSIMapSearchViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MSIMapSearchViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    func keyboardWillShow(_ notification: NSNotification){
        // Do something here
    }

    func keyboardWillHide(_ notification: NSNotification) {
        self.searchView?.searchBar?.showsCancelButton = false
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    private func mockDataForTableView() {
        self.dataFromDataset = self.delegate?.getAllAnnotationsInMap()
        self.allFilteredLayerNames = self.delegate?.getLayerNames()
        self.allFilteredLayerDataShownType = [LayerDataShownType]()
        if let theLayerNames = self.allFilteredLayerNames {
            if theLayerNames.count > 1 {
                for _ in 0..<theLayerNames.count {
                    self.allFilteredLayerDataShownType?.append(.showPart)
                }
            } else if theLayerNames.count == 1 {
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

        var allFilteredAnnotations = [String: [MSIMWAnnotation]]()
        var allFilteredLayerNames = [String]()
        var allLayerDataShownType = [LayerDataShownType]()
        var totalCount = 0
        if let allLayerNames = delegate?.getLayerNames(), let allAnnotations = delegate?.getAllAnnotationsInMap() {
            for index in 0..<allLayerNames.count {
                let layerName = allLayerNames[index]
                if let allAnnotationsInLayer = allAnnotations[layerName] {
                    var filteredAnnotationsInLayer: [MSIMWAnnotation] = [MSIMWAnnotation]()
                    for annotation in allAnnotationsInLayer {
                        let annotationName = annotation.getFirstAttributeDisplayFormValue()
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

        if self.searchView?.searchType == .fromDataset {
            self.searchView?.updateTableView()
        }
        self.searchView?.updateSearchTypeControl(index: 0, count: totalCount)

        if totalCount > 0 {
            self.searchView?.setSearchViewState(to: .endSearchingWithResults)
        }

        delegate?.highlightAnnotations(annotations: allFilteredAnnotations)
    }

    public func searchFromAppleService(for keyword: String?) {
        func checkLocalDatasetResult() {
            if let theDataFromDataset = self.dataFromDataset {
                if theDataFromDataset.count == 0 {
                    self.searchView?.setSearchViewState(to: .endSearchingWithoutResults)
                }
            } else {
                self.searchView?.setSearchViewState(to: .endSearchingWithoutResults)
            }
        }

        guard let mapView = self.mapView else {
            return
        }

        if self.localSearch != nil {
            self.localSearch!.cancel()
            self.localSearch = nil
        }

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = keyword
        request.region = mapView.region

        self.localSearch = MKLocalSearch(request: request)
        self.localSearch?.start(completionHandler: {(response, error) in
            guard let response = response else {
                print("Search error: \(error)")
                self.searchView?.updateSearchTypeControl(index: 1, count: 0)
                checkLocalDatasetResult()
                return
            }

            if let theDataFromDataset = self.dataFromDataset {
                if theDataFromDataset.count == 0 {
                    self.searchView?.setSearchViewState(to: .endSearchingWithResults)
                }
            }

            self.dataFromAppleService = response.mapItems
            if self.searchView?.searchType == .fromAppleService {
                self.searchView?.updateTableView()
            }
            var totalCount = 0
            if let theDataFromAppleService = self.dataFromAppleService {
                totalCount = theDataFromAppleService.count
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

    func getRows(for section: Int) -> [MSIMWAnnotation]? {
        guard let theLayerNames = self.allFilteredLayerNames else {
            return nil
        }

        guard section < theLayerNames.count else {
            return nil
        }

        let layerName = theLayerNames[section]
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

//        if self.searchView?.searchType == .fromDataset {
//            self.filterAnnotations(for: searchText)
//        } else if self.searchView?.searchType == .fromAppleService {
//            self.searchFromAppleService(for: searchText)
//        }
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NSLog("Cancel button is clicked")
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.searchView?.setSearchViewState(to: .beforeBegining)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NSLog("Search button is clicked")
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin editing")
        searchBar.showsCancelButton = true
        self.searchView?.setSearchViewState(to: .beginToSearch)
        for subview in searchBar.subviews[0].subviews {
            if let subview = subview as? UIButton {
                subview.tintColor = SearchViewUIConstants.searchBarCancelButtonTintColor
            }
        }
    }

}

extension MSIMapSearchViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MSIMapSearchTableCellView? = tableView.dequeueReusableCell(withIdentifier: SearchViewUIConstants.TableView.cellReuseIdentifier) as? MSIMapSearchTableCellView
        if cell == nil {
            cell = MSIMapSearchTableCellView(style: UITableViewCellStyle.default, reuseIdentifier: SearchViewUIConstants.TableView.cellReuseIdentifier)
        }
        var cellText = "--"
        if let lSearchView = self.searchView {
            switch lSearchView.searchType {
            case .fromDataset:
                let section = indexPath[0]
                let row = indexPath[1]
                let annotations = self.getRows(for: section)
                guard let theAnnotations = annotations else {
                    break
                }
                cellText = theAnnotations[row].getFirstAttributeDisplayFormValue()!
                break
            case .fromAppleService:
                if let theDataFromAppleService = self.dataFromAppleService {
                    let mapItem = theDataFromAppleService[indexPath[1]]
                    if let name = mapItem.name {
                        cellText = name
                    }
                }
                break
            }
            cell?.createLabels(searchType: lSearchView.searchType, contentString: cellText)
        }

        return cell!
    }
}

extension MSIMapSearchViewController: UITableViewDelegate {

    private func getRemainningCount(for section: Int) -> Int {
        guard let theLayerNames = self.allFilteredLayerNames else {
            return 0
        }

        guard section < theLayerNames.count else {
            return 0
        }

        var remainningCount = 0

        if let annotations = self.dataFromDataset?[theLayerNames[section]] {
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
                break
            case .showAll:
                footerText = "Hide"
                break
            }
        }

        return footerText
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        if let lSearchType = self.searchView?.searchType {
            switch lSearchType {
            case .fromDataset:
                guard let theLayerNames = self.allFilteredLayerNames else {
                    break
                }
                sectionCount = theLayerNames.count
                break
            case .fromAppleService:
                sectionCount = 1
                break
            }
        }

        return sectionCount

    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.searchView?.searchType == .fromDataset, let theAllFilteredLayerNames = self.allFilteredLayerNames {
            if theAllFilteredLayerNames.count > 1 {
                let headerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: SearchViewUIConstants.TableView.sectionHeaderHeight))
                let header = MSIMapSearchTableViewHeader(frame: headerFrame, theText: theAllFilteredLayerNames[section])
                return header
            } else if theAllFilteredLayerNames.count == 1 {
                let headerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: SearchViewUIConstants.TableView.sectionSpace))
                let header = MSIMapSearchTableViewHeader(frame: headerFrame, theText: nil)
                return header
            }
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.searchView?.searchType == .fromDataset {
            let footerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: SearchViewUIConstants.TableView.sectionFooterHeight))
            let footer = MSIMapSearchTableViewFooter(frame: footerFrame, theSection: section, theDelegate: self)
            footer.createButton(text: self.getFooterText(for: section))

            return footer
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.searchView?.searchType == .fromDataset, let theAllFilteredLayerNames = self.allFilteredLayerNames {
            if theAllFilteredLayerNames.count > 1 {
                return SearchViewUIConstants.TableView.sectionHeaderHeight
            } else if theAllFilteredLayerNames.count == 1 {
                return SearchViewUIConstants.TableView.sectionSpace
            }
        }

        return 0
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.searchView?.searchType == .fromDataset {
            return SearchViewUIConstants.TableView.sectionFooterHeight
        }

        return 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let lSearchView = self.searchView {
            switch lSearchView.searchType {
            case .fromDataset:
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
                break
            case .fromAppleService:
                if let count = self.dataFromAppleService?.count {
                    rows = count
                }
                break
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
    }
}

extension MSIMapSearchViewController: MSIMapSearchTableViewFooterDelegate {
    func showTypeChange(for section: Int) {
        if let layerDataShownType = self.allFilteredLayerDataShownType?[section] {
            switch layerDataShownType {
            case .showPart:
                self.allFilteredLayerDataShownType?[section] = .showAll
                break
            case .showAll:
                self.allFilteredLayerDataShownType?[section] = .showPart
                break
            }
        }

        self.searchView?.updateTableView()
    }
}
