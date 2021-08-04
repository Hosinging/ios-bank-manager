//
//  BankManager.swift
//  Created by yagom.
//  Copyright © yagom academy. All rights reserved.
//

import Foundation

struct BankManager {
    enum Menu: Int {
        case openingBank = 1
        case exit = 2
    }
    
    // MARK:- Property
    private let bank = Bank()
}

// MARK:- run() related Methods
extension BankManager {
    private func inputFromUser() throws -> Menu {
        showMenu()
        guard let input = readLine(),
              let inputNumber = Int(input),
              let menuNumber = Menu(rawValue: inputNumber) else {
            throw BankManagerError.wrongInput
        }
        return menuNumber
    }
    
    private func executeBankBusiness() {
        let bankTellers = generateBankTellers(roles: [.deposit, .deposit, .loan])
        bank.setBankTellers(bankTellers: bankTellers)
        
        let clients = generateClients()
        bank.receiveClient(clients: clients)
        bank.readyForWork()
        let task: TaskReport = bank.doTask()
        showClosingMessage(numberOfClient: task.numberOfClient, totalTaskTime: task.totalTaskTime)
        bank.finishWork()
    }
    
    func run() {
        do {
            while true {
                let userInput = try inputFromUser()
                switch userInput {
                case .openingBank:
                    executeBankBusiness()
                case .exit:
                    return
                }
            }
        } catch {
            showErrorDescription(message: error)
        }
    }
}

// MARK:- print() related Methods
extension BankManager {
    private func showMenu() {
        let menu = """
            1 : 은행개점
            2 : 종료
            입력 :
            """
        print(menu, terminator: " ")
    }
    
    private func showErrorDescription(message: Error) {
        if let error = message as? BankManagerError {
            print(error.errorDescription ?? "")
            return
        }
        print("예기치 못한 오류 발생. 프로그램을 종료합니다.")
    }
    
    private func showClosingMessage(numberOfClient: UInt, totalTaskTime: Double) {
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(numberOfClient)명이며, 총 업무시간은 \(String(format: "%.2f", totalTaskTime))초 입니다.")
    }
}

// MARK:- ETC. private Methods
extension BankManager {
    private func generateClients() -> [Client] {
        var clients: [Client] = []
        let clientRange = ClientCount.minimumCount...ClientCount.maximunCount
        let randomNumber = Int.random(in: clientRange)
        
        for _ in 0..<randomNumber {
            let client = Client()
            clients.append(client)
        }
        return clients
    }
    
    func generateBankTellers(roles: [TaskCategory]) -> [BankTeller] {
//        let bankTellers: [BankTeller] = roles.map { role in BankTeller(role: role) }
        var bankTellers: [BankTeller] = []
        for role in roles {
            bankTellers.append(BankTeller(role: role))
        }
        return bankTellers
    }
}
