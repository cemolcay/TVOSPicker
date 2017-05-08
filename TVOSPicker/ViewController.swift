//
//  ViewController.swift
//  TVOSPicker
//
//  Created by Cem Olcay on 08/05/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBAction func pickerButtonPressed(sender: UIButton) {
    var dataSource = Array(0..<10).map({ "Item \($0)" })
    dataSource.insert("Some big item", at: 1)
    dataSource.insert("Some other big item", at: 4)

    presentPicker(
      title: "Example Picker",
      subtitle: "Some optional explanation message about what this picker picks",
      dataSource: dataSource,
      initialSelection: 0,
      onSelectItem: { item, index in
        print("\(item) selected at index \(index)")
      })
  }
}
