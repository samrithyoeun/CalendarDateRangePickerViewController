//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

public protocol CalendarDateRangePickerViewControllerDelegate {
    func didCancelPickingDateRange()
    func didPickDateRange(startDate: Date!, endDate: Date!)
}

public class CalendarDateRangePickerViewController: UICollectionViewController {
    
    let cellReuseIdentifier = "CalendarDateRangePickerCell"
    let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
    
    public var delegate: CalendarDateRangePickerViewControllerDelegate!
    
    let itemsPerRow = 7
    let itemHeight: CGFloat = 40
    var collectionViewInsets = UIEdgeInsets(top: 100, left: 25, bottom: 150, right: 25)
    
    public var minimumDate: Date!
    public var maximumDate: Date!
    
    public var selectedStartDate: Date?
    public lazy var selectedEndDate = selectedStartDate
    
    public var selectedColor = UIColor(red: 15/255.0, green: 147/255.0, blue: 189/255.0, alpha: 1.0)
    public var titleText = "Select Dates"
    
    // customize by sam
    public var showBottomView = true
    public var singleDateSelection = false
    public var sectionNumber  = 0
    public var scrollToTop = false
    public var holidays = [String]()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if singleDateSelection == false  {
            collectionView?.contentInset = collectionViewInsets
            bottomView()
        } else {
            collectionView?.contentInset = UIEdgeInsets(top: 100, left: 25, bottom: 100, right: 25)
        }
        
        self.title = self.titleText
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        
        if minimumDate == nil {
            minimumDate = Date()
        }
        if maximumDate == nil {
            maximumDate = Calendar.current.date(byAdding: .year, value: 3, to: minimumDate)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(CalendarDateRangePickerViewController.didTapCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CalendarDateRangePickerViewController.didTapDone))
        self.navigationItem.leftBarButtonItem?.tintColor = selectedColor
        self.navigationItem.rightBarButtonItem?.tintColor = selectedColor
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedStartDate != nil
        
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let difference = Calendar.current.dateComponents([.month], from: minimumDate, to: Calendar.current.date(byAdding: .month, value: 1, to: maximumDate)!)
        let section = difference.month! - 3
        print("section \(section)")
        
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        let row = weekdayRowItems + blankItems + daysInMonth
        print(row)
        if scrollToTop == true {
            collectionView?.scrollToItem(at: [0,0], at: .top, animated: true)
        } else {
            print("scrolling to bottom")
            collectionView?.scrollToItem(at: [collectionView!.numberOfSections - 1 , 20], at: .bottom, animated: true)
        }
        
        
    }
    
    public func bottomView() {
        let mView = UIView()
        mView.backgroundColor = selectedColor
        mView.frame = CGRect(x: 0, y: view.bounds.height - 75, width: view.frame.width, height: 75)
        
        let buttonWidth =  Int( mView.frame.width / 3 - 15 )
        let buttonHeight = 35
        
        let button = UIButton()
        button.setTitle("TODAY", for: .normal)
        button.frame = CGRect(x: 10, y: 20, width: buttonWidth, height: buttonHeight )
        button.addTarget(self, action: #selector(CalendarDateRangePickerViewController.todayButtonTapped), for: .touchUpInside)
        
        let button1 = UIButton()
        button1.setTitle("LAST WEEK", for: .normal)
        button1.frame = CGRect(x: buttonWidth + 20 , y: 20, width: buttonWidth, height: buttonHeight)
        button1.addTarget(self, action: #selector(CalendarDateRangePickerViewController.thisWeekButtonTapped), for: .touchUpInside)
        
        let button2 = UIButton()
        button2.setTitle("THIS MONTH", for: .normal)
        button2.frame = CGRect(x: buttonWidth * 2 + 30 , y: 20, width: buttonWidth, height: buttonHeight )
        button2.addTarget(self, action: #selector(CalendarDateRangePickerViewController.thisMonthButtonTapped), for: .touchUpInside)
        
        let buttons = [button, button1, button2]
        for button in buttons {
            button.titleLabel?.font = UIFont.init(name: "Roboto-Bold", size: 15)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = button.frame.height / 2
        }
        
        mView.addSubview(button)
        mView.addSubview(button1)
        mView.addSubview(button2)
        view.addSubview(mView)
    }
    
    @objc func todayButtonTapped() {
        delegate.didPickDateRange(startDate: Date(), endDate: Date())
    }
    
    @objc func thisWeekButtonTapped() {
        delegate.didPickDateRange(startDate: Date().lastWeek.startOfWeek() , endDate: Date().lastWeek.endOfWeek())
    }
    
    @objc func thisMonthButtonTapped() {
        delegate.didPickDateRange(startDate: Date().startOfMonth(), endDate: Date().endOfMonth())
    }
    
    @objc func didTapCancel() {
        delegate.didCancelPickingDateRange()
    }
    
    @objc func didTapDone() {
        
        if selectedStartDate == nil || selectedEndDate == nil {
            if selectedStartDate != nil && selectedEndDate == nil {
                selectedEndDate = selectedStartDate
            } else {
                return
            }
        }
        delegate.didPickDateRange(startDate: selectedStartDate!, endDate: selectedEndDate!)
    }
    
}

extension CalendarDateRangePickerViewController {
    
    // UICollectionViewDataSource
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        let difference = Calendar.current.dateComponents([.month], from: minimumDate, to: Calendar.current.date(byAdding: .month, value: 1, to: maximumDate)!)
        return difference.month! + 1
        
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
        
        
        
        cell.selectedColor = self.selectedColor
        cell.reset()
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item < 7 {
            cell.label.text = getWeekdayLabel(weekday: indexPath.item + 1)
        } else if indexPath.item < 7 + blankItems {
            cell.label.text = ""
        } else {
            let dayOfMonth = indexPath.item - (7 + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.label.text = "\(dayOfMonth)"
            
            if holidays.contains(cell.date!.getShortDate()){
                cell.disable()
            }
            
            if (cell.date! > maximumDate) {
                cell.disable()
            }
            if isBefore(dateA: date, dateB: minimumDate) {
                cell.disable()
            }
            if cell.date!.isWeekend {
                cell.disable()
            }
            
            // customize Single section feature
            if singleDateSelection == false {
                if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                    // Cell falls within selected range
                    if dayOfMonth == 1 {
                        cell.highlightRight()
                    } else if dayOfMonth == getNumberOfDaysInMonth(date: date) {
                        cell.highlightLeft()
                    } else {
                        cell.highlight()
                    }
                } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                    // Cell is selected start date
                    cell.select()
                    if selectedEndDate != nil {
                        cell.highlightRight()
                    }
                } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                    cell.select()
                    cell.highlightLeft()
                }
            } else {
                selectedEndDate = selectedStartDate
                if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                    // Cell falls within selected range
                    if dayOfMonth == 1 {
                        cell.highlightRight()
                    } else if dayOfMonth == getNumberOfDaysInMonth(date: date) {
                        cell.highlightLeft()
                    } else {
                        cell.highlight()
                    }
                } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                    // Cell is selected start date
                    cell.select()
                    if selectedEndDate != nil {
                        cell.singleDatehighlight()
                    }
                } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                    cell.select()
                    cell.highlightLeft()
                }
            }
            
        }
        
        
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            if #available(iOS 8.2, *) {
                headerView.label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            } else {
                // Fallback on earlier versions
            }
            headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
}

extension CalendarDateRangePickerViewController : UICollectionViewDelegateFlowLayout {
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        
        if cell.date == nil {
            return
        }
        
        if cell.date!.isWeekend {
            return
        }
        
        if isBefore(dateA: cell.date!, dateB: minimumDate) {
            return
        }
        if cell.date! > maximumDate {
            return
        }
        
        if holidays.contains(cell.date!.getShortDate()) {
            return
        }
        
        if selectedStartDate == nil {
            selectedStartDate = cell.date
        } else if selectedEndDate == nil {
            if isBefore(dateA: selectedStartDate!, dateB: cell.date!) {
                selectedEndDate = cell.date
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                // If a cell before the currently selected start date is selected then just set it as the new start date
                selectedStartDate = cell.date
            }
        } else {
            selectedStartDate = cell.date
            selectedEndDate = nil
        }
        collectionView.reloadData()
    }
    
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension CalendarDateRangePickerViewController {
    
    // Helper functions
    
    func getFirstDate() -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: minimumDate)
        components.day = 1
        return Calendar.current.date(from: components)!
    }
    
    func getFirstDateForSection(section: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: section, to: getFirstDate())!
    }
    
    func getMonthLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getWeekdayLabel(weekday: Int) -> String {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.weekday = weekday
        let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
        if date == nil {
            return "E"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date!)
    }
    
    func getWeekday(date: Date) -> Int {
        return Calendar.current.dateComponents([.weekday], from: date).weekday!
    }
    
    func getNumberOfDaysInMonth(date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    func getDate(dayOfMonth: Int, section: Int) -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
        components.day = dayOfMonth
        return Calendar.current.date(from: components)!
    }
    
    func areSameDay(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
    }
    
    func isBefore(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedAscending
    }
    
}

extension Date {
    var isWeekend: Bool {
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.isDateInWeekend(self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var lastWeek: Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func startOfWeek() -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    func endOfWeek() -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    func getShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: self)
    }
    
}

