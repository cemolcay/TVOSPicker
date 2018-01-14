TVOSPicker
===

A sweet horizontal picker view controller for tvOS.

Demo
----

![alt tag](https://github.com/cemolcay/TVOSPicker/blob/master/demo.gif?raw=true)

Requirements
----

- Swift 4.0+
- tvOS 9.0+

Install
----

```
# in your tvOS target
use_frameworks!
pod 'TVOSPicker'
```

Usage
----

There are two ways to use this library.  
- First one is with traditional ways, create either programmatically or from storyboard, a `TVOSPickerViewController` instance and implement its delegate methods, set `dataSource`, `titleLabel` and `subtitleLabel` texts.
- Other one is call `presentPicker(title:subtitle:dataSource:initialSelection:onSelectItem)` on your presenting view controller.
- If your view controller has a navigation controller, than `TVOSPickerViewController` would be pushed by navigation controller and pop after a cancellation or a selection.
- Otherwise, it would be presented modally over the presenting view controller. So, you should be careful when you call it over an already modally presented view controller. I recommend you to wrap it with a navigation controller if you tend to present a picker from a modally presented view controller.