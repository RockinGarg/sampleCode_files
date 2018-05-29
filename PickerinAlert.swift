//
//  Extensions.swift
//  ServiceApp-TimeSlots
//
//  Created by IosDeveloper on 25/04/18.
//  Copyright © 2018 ServiceApp. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

extension Date {
    var localTime: String {
        return description(with: Locale.current)
    }
}

final class DatePickerViewController: UIViewController {
    
    public typealias Action = (Date) -> Void
    
    fileprivate var action: Action?
    
    fileprivate lazy var datePicker: UIDatePicker = { [unowned self] in
        $0.addTarget(self, action: #selector(DatePickerViewController.actionForDatePicker), for: .valueChanged)
        return $0
        }(UIDatePicker())
    
    required init(mode: UIDatePickerMode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.locale = Locale.current
        datePicker.date = date ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
//        datePicker.timeZone = TimeZone(abbreviation: "GMT")
        self.action = action
        action?(datePicker.date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("has deinitialized")
    }
    
    override func loadView() {
        view = datePicker
    }
    
    @objc func actionForDatePicker() {
        action?(datePicker.date)
    }
    
    public func setDate(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
}

extension UIView
{
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}


extension UIAlertController
{
    func addDatePicker(mode: UIDatePickerMode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, action: DatePickerViewController.Action?) {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, action: action)
        set(vc: datePicker, height: 217)
    }
    
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
    
    public func show(animated: Bool = true, vibrate: Bool = false, style: UIBlurEffectStyle? = nil, completion: (() -> Void)? = nil) {
        
        /// TODO: change UIBlurEffectStyle
        if let style = style {
            for subview in view.allSubViewsOf(type: UIVisualEffectView.self) {
                subview.effect = UIBlurEffect(style: style)
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
            if vibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }
}

extension swiftCode{
    /// Usage
    @IBAction func selectMaxdate(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Select maximum time", message: "", preferredStyle: .actionSheet)
        alert.addDatePicker(mode: .time, date: Date(), minimumDate: self.minimumTime?.addingTimeInterval(15*60), maximumDate: nil) { date in
            self.maximumTime = date
            self.mnaximumDateLabel.text = self.getDateFormat(inputDate: self.maximumTime!, format: .time)
            self.updateValuesOfTimeStrings(inputDate: date, timeCase: .maximum)
            
        }
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        alert.show()
    }
}
