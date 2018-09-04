import Foundation
import UIKit

func showAlert(controller: UIViewController) {
    let alert: UIAlertController = UIAlertController(title: "Stock already in Portfolio", message: "Click on stock to buy or sell", preferredStyle: .alert)
    let action1: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(action1)
    DispatchQueue.main.async {
        controller.present(alert, animated: true)
    }
}

func showInsufficientFundsAlert(controller: UIViewController) {
    let accountAlert: UIAlertController = UIAlertController(title: "Error", message: "Insufficient funds in account", preferredStyle: .alert)
    let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
    accountAlert.addAction(action1)
    controller.present(accountAlert, animated: true)
}

func invalidInputAlert(controller: UIViewController) {
    let inputAlert: UIAlertController = UIAlertController(title: "Error", message: "Number must be a positive integer", preferredStyle: .alert)
    let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
    inputAlert.addAction(action1)
    controller.present(inputAlert, animated: true)
}

func invalidStockAlert(controller: UIViewController) {
    let stockAlert: UIAlertController = UIAlertController(title: "Error", message: "Please enter a valid stock symbol", preferredStyle: .alert)
    let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
    stockAlert.addAction(action1)
    controller.present(stockAlert, animated: true)
}

func insufficientFundsAlert(controller: UIViewController) {
    let fundsAlert: UIAlertController = UIAlertController(title: "Error", message: "Insufficient funds for this transaction", preferredStyle: .alert)
    let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
    fundsAlert.addAction(action1)
    controller.present(fundsAlert, animated: true)
}

func insufficientSharesAlert(controller: UIViewController) {
    let alert: UIAlertController = UIAlertController(title: "Error", message: "You do not have enough shares for this transaction", preferredStyle: .alert)
    let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
    alert.addAction(action1)
    controller.present(alert, animated: true)
}
