//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by Jost, Hosinging on 2021/07/29.
//

import Foundation

typealias TaskReport = (UInt, Double)

class Bank {
    // MARK:- private Properties
    private var bankTellers: [BankTeller] = []
    private var clientQueue = Queue<Client>()
    private var bankTellerQueue = Queue<BankTeller>()
    private var queueTicketMachine = QueueTicketMachine()
    
    // MARK:- initializer
    init(roles: [TaskCategory]) {
        for role in roles {
            let bankTeller = BankTeller(role: role)
            bankTellers.append(bankTeller)
        }
    }
}

// MARK:- private Methods
extension Bank {
    private func issueWaitingNumberTicket(to client: Client) {
        let queueTicket = queueTicketMachine.issueWatingNumberTicket()
        client.setQueueTicket(queueTicket: queueTicket)
    }
    
    private func calculateTotalTaskTime(start: DispatchTime, end: DispatchTime) -> Double {
        return Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000000
    }
}

// MARK:- internal Methods (BankManager executeBankBusiness() 에서 호출되는 메서드들)
extension Bank {
    func readyForWork() {
        for bankTeller in bankTellers {
            bankTellerQueue.enqueue(value: bankTeller)
        }
    }
    
    func receiveClient(clients: [Client]) {
        for client in clients {
            issueWaitingNumberTicket(to: client)
            clientQueue.enqueue(value: client)
        }
    }
    
    func doTask() -> TaskReport {
        let startTime = DispatchTime.now()
        
        while self.clientQueue.isNotEmpty() {
            DispatchQueue.global().async {
                if self.bankTellerQueue.isNotEmpty(),
                   let client = self.clientQueue.dequeue(),
                   let bankTeller = self.bankTellerQueue.dequeue() {
                    bankTeller.handleTask(with: client)
                    self.bankTellerQueue.enqueue(value: bankTeller)
                }
            }
        }
        
        let endTime = DispatchTime.now()
        let totalTaskTIme = calculateTotalTaskTime(start: startTime, end: endTime)
        let numberOfClient = queueTicketMachine.getCurrentTicketNumber
        
        return (numberOfClient, totalTaskTIme)
    }
    
    func finishWork() {
        queueTicketMachine.reset()
        clientQueue.clear()
        bankTellerQueue.clear()
    }
}
