//
//  MSIMapSearchView.swift
//  MicroStrategyMobile
//
//  Created by Zhang, Hongchao on 12/6/16.
//  Copyright © 2016 MicroStratgy Inc. All rights reserved.
//

import Foundation
import UIKit

public struct SearchViewUIConstants {

    static let cornerRadius: CGFloat = 4.0

    static let searchBarCancelButtonTintColor = UIColor(red: 0x27/255.0, green: 0xA7/255.0, blue: 0xEE/255.0, alpha: 1.0)

    static let fontFamily: String = ".SFUIText-Regular"
    static let highlightFontFamily: String = ".SFUIText-Bold"

    public struct SearchBar {
        static let height: CGFloat = 30.0
        static let padding: CGFloat = 10.0
        static let topMargin: CGFloat = 16.0
        static let leftMargin: CGFloat = 20.0
        static let rightMargin: CGFloat = 20.0
        static let bottomMargin: CGFloat = 20.0
        static let widthFor290Container: CGFloat = 250.0
        static let widthFor250Container: CGFloat = 210.0
        static let searchFieldCornerRadius: CGFloat = 4.0
        static let searchFiledBorderWidth: CGFloat = 1.0
        static let searchFieldBorderColor = UIColor(red: 0xC2/255.0, green: 0xC8/255.0, blue: 0xCE/255.0, alpha: 1.0)
        static let searchFieldBackgroundNormalColor = UIColor(red: 0xFF/255.0, green: 0xFF/255.0, blue: 0xFF/255.0, alpha: 0.5)
        static let searchFieldBackgroundEditorColor = UIColor(red: 0xFF/255.0, green: 0xFF/255.0, blue: 0xFF/255.0, alpha: 1.0)
    }

    public struct SearchTypeButton {
        static let height: CGFloat = 30.0
        static let bottomMargin: CGFloat = 16.0
    }

    public struct TableView {
        static let rowHeight: CGFloat = 44.0
        static let sectionHeaderHeight: CGFloat = 32.0
        static let sectionFooterHeight: CGFloat = 24.0
        static let bottomMargin: CGFloat = 50.0
        static let defaultDisplayCount: Int = 5
        static let rightMarginForIcon: CGFloat = 10.0
        static let sectionSpace: CGFloat = 16.0
        static let cellReuseIdentifier = "search_results_cell"
        static let footerButtonTintColor = UIColor(red: 0x27/255.0, green: 0xAF/255.0, blue: 0xEE/255.0, alpha: 1.0)
        static let footerFontSize: CGFloat = 14.0
        static let headerLabelColor = UIColor(red: 0xA4/255.0, green: 0xA4/255.0, blue: 0xA4/255.0, alpha: 1.0)
        static let headerFontSize: CGFloat = 12.0
        static let sectionSeparatorHeight: CGFloat = 0.5
        static let cellFontSize: CGFloat = 14.0
        static let cellTextColor = UIColor(red: 0x3F/255.0, green: 0x40/255.0, blue: 0x42/255.0, alpha: 1.0)
    }

    public struct DraggingIconContainer {
        static let height: CGFloat = 20.0
    }
    public struct DraggingIcon {
        static let width: CGFloat = 20.0
        static let height: CGFloat = 2.0
        static let bottomMargin: CGFloat = 5.0
    }

    public struct MessageLabel {
        static let fontSize: CGFloat = 14.0
        static let height: CGFloat = 30.0
        static let bottomMargin: CGFloat = 20.0
    }
}

public enum SearchType {
    case fromDataset
    case fromAppleService
}

public enum SearchViewState {
    case beforeBegining
    case beginToSearch
    case endSearchingWithoutResults
    case endSearchingWithResults
}

public class MSIMapSearchView: UIView {
    var searchBar: UISearchBar?
    var messageLabel: UILabel?
    var searchTypeControl: UISegmentedControl?
    var tableView: UITableView?
    var draggingContainer: UIView?
    var maxFrame: CGRect
    var searchType: SearchType {
        var lSearchType: SearchType = .fromDataset
        if let lSearchTypeControl = self.searchTypeControl {
            switch lSearchTypeControl.selectedSegmentIndex {
            case 0:
                lSearchType = .fromDataset
                break
            case 1:
                lSearchType = .fromAppleService
                break
            default:
                break
            }
        }

        return lSearchType
    }

    override init(frame: CGRect) {
        maxFrame = frame
        super.init(frame: frame)
        self.layer.cornerRadius = SearchViewUIConstants.cornerRadius
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let tableView = self.tableView {
            if tableView.isHidden == false {
                self.tableView?.frame = self.getTableViewFrame()
            }
        }

        if let draggingContainer = self.draggingContainer {
            if draggingContainer.isHidden == false {
                self.draggingContainer?.frame = self.getDraggingContainerFrame()
            }
        }

    }

    func createInitView() {
        self.backgroundColor = UIColor.white

        self.searchBar = self.createSearchBar()
        self.addSubview(self.searchBar!)

        self.messageLabel = self.createMessageLabel()
        self.addSubview(self.messageLabel!)

        self.searchTypeControl = self.createSearchTypeControl()
        self.addSubview(self.searchTypeControl!)

        self.tableView = self.createTableView()
        self.addSubview(self.tableView!)

        self.draggingContainer = self.createDraggingView()
        self.addSubview(self.draggingContainer!)

        self.createDraggingGesture()

    }

    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        return image!
    }

    func setSearchViewState(to state: SearchViewState) {
        switch state {
        case .beforeBegining:
            self.searchBar?.showsCancelButton = false
            self.searchBar?.setSearchFieldBackgroundImage(MSIMapSearchView.image(with: SearchViewUIConstants.SearchBar.searchFieldBackgroundNormalColor), for: UIControlState.normal)

            self.backgroundColor = UIColor.clear
            let height = self.searchBar!.frame.origin.y + self.searchBar!.frame.size.height + SearchViewUIConstants.SearchBar.bottomMargin
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.bounds.size.width, height: height))

            self.messageLabel?.isHidden = true
            self.searchTypeControl?.isHidden = true
            self.tableView?.isHidden = true
            self.draggingContainer?.isHidden = true
            break
        case .beginToSearch:
//            self.searchBar?.searchBarStyle = .prominent
//            self.searchBar?.setBackgroundImage(self.image(with: UIColor.clear), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            self.searchBar?.setSearchFieldBackgroundImage(MSIMapSearchView.image(with: SearchViewUIConstants.SearchBar.searchFieldBackgroundEditorColor), for: UIControlState.normal)

            self.backgroundColor = UIColor.white
            let height = self.messageLabel!.frame.origin.y + self.messageLabel!.frame.size.height + SearchViewUIConstants.MessageLabel.bottomMargin
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.bounds.size.width, height: height))

            self.messageLabel?.text = "Search from dataset or map."
            self.messageLabel?.isHidden = false
            self.searchTypeControl?.isHidden = true
            self.tableView?.isHidden = true
            self.draggingContainer?.isHidden = true
            break
        case .endSearchingWithoutResults:
//            self.searchBar?.searchBarStyle = .prominent
//            self.searchBar?.setBackgroundImage(self.image(with: UIColor.clear), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            self.searchBar?.setSearchFieldBackgroundImage(MSIMapSearchView.image(with: SearchViewUIConstants.SearchBar.searchFieldBackgroundEditorColor), for: UIControlState.normal)

            self.backgroundColor = UIColor.white
            let height = self.messageLabel!.frame.origin.y + self.messageLabel!.frame.size.height + SearchViewUIConstants.MessageLabel.bottomMargin
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.bounds.size.width, height: height))

            self.messageLabel?.text = "No results found."
            self.messageLabel?.isHidden = false
            self.searchTypeControl?.isHidden = true
            self.tableView?.isHidden = true
            self.draggingContainer?.isHidden = true
            break
        case .endSearchingWithResults:
//            self.searchBar?.searchBarStyle = .prominent
//            self.searchBar?.setBackgroundImage(self.image(with: UIColor.clear), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            self.searchBar?.setSearchFieldBackgroundImage(MSIMapSearchView.image(with: SearchViewUIConstants.SearchBar.searchFieldBackgroundEditorColor), for: UIControlState.normal)

            self.messageLabel?.isHidden = true
            self.searchTypeControl?.isHidden = false
            self.tableView?.isHidden = false
            self.draggingContainer?.isHidden = false
            self.backgroundColor = UIColor.white
            self.frame = self.maxFrame
            break
        }
    }

    private func createSearchBar() -> UISearchBar? {
        let frame = CGRect(x: SearchViewUIConstants.SearchBar.leftMargin - SearchViewUIConstants.SearchBar.padding,
                                 y: SearchViewUIConstants.SearchBar.topMargin - SearchViewUIConstants.SearchBar.padding,
                                 width: self.bounds.size.width - SearchViewUIConstants.SearchBar.leftMargin - SearchViewUIConstants.SearchBar.rightMargin + SearchViewUIConstants.SearchBar.padding * 2,
                                 height: SearchViewUIConstants.SearchBar.height + SearchViewUIConstants.SearchBar.padding * 2)
        let searchBar = MSIMapSearchBar(frame: frame)

        return searchBar
    }

    private func createMessageLabel() -> UILabel {
        let messageLabel = UILabel()
        messageLabel.isHidden = true
        messageLabel.textColor = UIColor(red: 0xA4/255.0, green: 0xA4/255.0, blue: 0xA4/255.0, alpha: 1.0)
        messageLabel.font = UIFont(name: ".SFUIText-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)

        var yPos: CGFloat = 0.0
        if let lSearchBar = self.searchBar {
            yPos = lSearchBar.frame.origin.y + lSearchBar.bounds.size.height + SearchViewUIConstants.SearchBar.bottomMargin - SearchViewUIConstants.SearchBar.padding
        }

        var width = self.bounds.size.width - SearchViewUIConstants.SearchBar.leftMargin - SearchViewUIConstants.SearchBar.rightMargin
        width = width > 0.0 ? width : 0.0

        messageLabel.frame = CGRect(x: SearchViewUIConstants.SearchBar.leftMargin,
                                    y: yPos,
                                    width: width,
                                    height: SearchViewUIConstants.MessageLabel.height)

        messageLabel.text = "Search from dataset or map"

        return messageLabel
    }

    private func createSearchTypeControl() -> UISegmentedControl {
        let searchTypeControl = UISegmentedControl()
        searchTypeControl.isHidden = true
        searchTypeControl.tintColor = UIColor(red: 0x27/255.0, green: 0xAF/255.0, blue: 0xEE/255.0, alpha: 1.0)

        var yPos: CGFloat = 0.0
        if let lSearchBar = self.searchBar {
            yPos = lSearchBar.frame.origin.y + lSearchBar.bounds.size.height + SearchViewUIConstants.SearchBar.bottomMargin - SearchViewUIConstants.SearchBar.padding
        }

        var width = self.bounds.size.width - SearchViewUIConstants.SearchBar.leftMargin - SearchViewUIConstants.SearchBar.rightMargin
        width = width > 0.0 ? width : 0.0

        searchTypeControl.frame = CGRect(x: SearchViewUIConstants.SearchBar.leftMargin,
                                         y: yPos,
                                         width: width,
                                         height: SearchViewUIConstants.SearchTypeButton.height)
        searchTypeControl.insertSegment(withTitle: "Dataset", at: 0, animated: false)
        searchTypeControl.insertSegment(withTitle: "Map", at: 1, animated: false)
        searchTypeControl.selectedSegmentIndex = 0
        searchTypeControl.addTarget(self, action: #selector(MSIMapSearchView.searchTypeChanged(segmentControl:)), for: UIControlEvents.valueChanged)
        
//        searchTypeControl.isHidden = true

        return searchTypeControl
    }

    func searchTypeChanged(segmentControl: UISegmentedControl) {
        self.updateTableView()
    }

    private func getTableViewFrame() -> CGRect {
        var yPos: CGFloat = 0.0
        if let lSearchTypeControl = self.searchTypeControl {
            yPos = lSearchTypeControl.frame.origin.y + lSearchTypeControl.bounds.size.height // the margin is inside the first header of the table view
        }

        var width = self.bounds.size.width - SearchViewUIConstants.SearchBar.leftMargin - SearchViewUIConstants.SearchBar.rightMargin
        width = width > 0.0 ? width : 0.0

        var height = self.bounds.size.height - yPos - SearchViewUIConstants.TableView.bottomMargin
        height = height > 0.0 ? height : 0.0

        let frame = CGRect(x: SearchViewUIConstants.SearchBar.leftMargin,
                                 y: yPos,
                                 width: width,
                                 height: height)

        return frame
    }

    private func createTableView() -> UITableView? {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.separatorColor = UIColor.clear

        tableView.frame = self.getTableViewFrame()
        tableView.reloadData()

//        tableView.backgroundColor = UIColor.lightGray

//        tableView.isHidden = true
        return tableView
    }

    private func getDraggingContainerFrame() -> CGRect {
        var yPos = self.frame.size.height - SearchViewUIConstants.DraggingIconContainer.height
        yPos = yPos > 0.0 ? yPos : 0.0

        var width = self.bounds.size.width - SearchViewUIConstants.SearchBar.leftMargin - SearchViewUIConstants.SearchBar.rightMargin
        width = width > 0.0 ? width : 0.0

        let frame = CGRect(x: SearchViewUIConstants.SearchBar.leftMargin,
                                            y: yPos,
                                            width: width,
                                            height: SearchViewUIConstants.DraggingIconContainer.height)

        return frame
    }

    private func createDraggingView() -> UIView {
        let draggingContainerFrame = self.getDraggingContainerFrame()
        let draggingContainer = UIView(frame: draggingContainerFrame)
        draggingContainer.isHidden = true
        draggingContainer.backgroundColor = UIColor.clear

        let draggingIconFrame  = CGRect(x: (draggingContainerFrame.size.width - SearchViewUIConstants.DraggingIcon.width) / 2,
                                        y: draggingContainerFrame.size.height - SearchViewUIConstants.DraggingIcon.height - SearchViewUIConstants.DraggingIcon.bottomMargin,
                                        width: SearchViewUIConstants.DraggingIcon.width,
                                        height: SearchViewUIConstants.DraggingIcon.height)
        let draggingIcon = UIView(frame: draggingIconFrame)
        draggingIcon.backgroundColor = UIColor.lightGray

        draggingContainer.addSubview(draggingIcon)

        return draggingContainer
    }

    private func createDraggingGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MSIMapSearchView.doPanning(panGesture:)))
        self.draggingContainer?.addGestureRecognizer(pan)
    }

    private func getMinimumHeight() -> CGFloat {
        var minHeight: CGFloat = SearchViewUIConstants.DraggingIconContainer.height
        if let lSearchTypeControl = self.searchTypeControl {
            minHeight += lSearchTypeControl.frame.origin.y + lSearchTypeControl.frame.size.height + SearchViewUIConstants.SearchTypeButton.bottomMargin
        } else if let lSearchBar = self.searchBar {
            minHeight += lSearchBar.frame.origin.y + lSearchBar.frame.size.height + SearchViewUIConstants.SearchBar.bottomMargin
        }

        return minHeight
    }

    @objc private func doPanning(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .changed {
            let verticalTranslation: CGFloat = panGesture.translation(in: self.draggingContainer).y
//            print("translation: \(verticalTranslation)")
            let oldFrame = self.frame
            var newHeight = oldFrame.size.height + verticalTranslation
            newHeight = newHeight > self.maxFrame.size.height ? self.maxFrame.size.height : newHeight
            let minHeight = self.getMinimumHeight()
            newHeight = newHeight > minHeight ? newHeight : minHeight
            let newFrame = CGRect(origin: oldFrame.origin, size: CGSize(width: oldFrame.size.width, height: newHeight))
            self.frame = newFrame
            panGesture.setTranslation(CGPoint.zero, in: self.draggingContainer)
        }
    }

    func setSearchBarDelegate(delegate: UISearchBarDelegate) {
        self.searchBar?.delegate = delegate
    }

    func setTableViewDelegate(delegate: UITableViewDelegate) {
        self.tableView?.delegate = delegate
    }

    func setTableViewDataSource(dataSource: UITableViewDataSource) {
        self.tableView?.dataSource = dataSource
    }

    func updateTableView() {
        self.tableView?.reloadData()
    }

    func updateSearchTypeControl(index: Int, count: Int) {
        var newTitle = ""
        if index == 0 {
            newTitle = "Dataset(\(count))"
        } else if index == 1 {
            newTitle = "Map(\(count))"
        }
        self.searchTypeControl?.setTitle(newTitle, forSegmentAt: index)
    }
}
