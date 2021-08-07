//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by Jost, Hosinging on 2021/07/29.
//

import Foundation

typealias TaskReport = (numberOfClient: UInt, totalTaskTime: Double)

class Bank {
    // MARK:- private Properties
    private var bankTellers: [BankTeller] = []
    private var waitingNumberTicketMachine = WaitingNumberTicketMachine()
    private var taskWaitingQueueMap: [TaskCategory: Queue<Client>] = [:]
    
    init () {
        for taskCase in TaskCategory.allCases {
            taskWaitingQueueMap[taskCase] = Queue<Client>()
        }
    }
}

// MARK:- private Methods
extension Bank {
    private func issueWaitingNumberTicket(to client: Client) {
        let waitingNumberTicket = waitingNumberTicketMachine.issueWatingNumberTicket()
        client.setQueueTicket(queueTicket: waitingNumberTicket)
    }
    
    private func calculateTotalTaskTime(start: DispatchTime, end: DispatchTime) -> Double {
        return Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000000
    }
}

// MARK:- internal Methods (BankManager executeBankBusiness() 에서 호출되는 메서드들)
extension Bank {
    func setBankTellers(bankTellers: [BankTeller]) {
        self.bankTellers = bankTellers
    }
    
    func receiveClient(clients: [Client]) {
        for client in clients {
            if let taskWaitingQueue = taskWaitingQueueMap[client.task] {
                issueWaitingNumberTicket(to: client)
                taskWaitingQueue.enqueue(value: client)
            }
        }
    }
    
    func isAllBankTellersNotCompleted() -> Bool {
        let notCompletedBankTeller = bankTellers.filter { $0.client != nil }
        return notCompletedBankTeller.count > 0
    }
    
    func isSomeClientsQueueNotEmpty() -> Bool {
        for (_, waitingQueue) in taskWaitingQueueMap {
            if waitingQueue.isNotEmpty() {
                return true
            }
        }
        return false
    }
    
    func handleTask(bankTeller: BankTeller, group: DispatchGroup) {
        if let waitingQueue = taskWaitingQueueMap[bankTeller.role],
           let client = waitingQueue.dequeue() {
            bankTeller.handleTask(with: client, group: group) {
                self.handleTask(bankTeller: bankTeller, group:group)
            }
        }
    }
    
    func doTask() -> TaskReport {
        let startTime = DispatchTime.now()
        let group = DispatchGroup()
        for bankTeller in bankTellers {
            DispatchQueue.global().async(group: group) {
                self.handleTask(bankTeller: bankTeller, group: group)
            }
        }
        
        group.wait()
//        while isSomeClientsQueueNotEmpty() || isAllBankTellersNotCompleted() {}
        
        let endTime = DispatchTime.now()
        let totalTaskTIme = calculateTotalTaskTime(start: startTime, end: endTime)
        let numberOfClient = waitingNumberTicketMachine.getCurrentTicketNumber
        
        return (numberOfClient, totalTaskTIme)
    }
    
    func finishWork() {
        waitingNumberTicketMachine.reset()

        for (_, taskQueue) in taskWaitingQueueMap {
            taskQueue.clear()
        }
    }
}
