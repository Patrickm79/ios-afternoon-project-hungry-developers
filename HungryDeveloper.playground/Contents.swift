import Foundation
import Dispatch
/*
class Spoon {
    private let lock = NSLock()
    let index: Int

    init(index: Int) {
        self.index = index
    }

    func pickUp() {
        lock.lock()
    }

    func putDown() {
        lock.unlock()
    }
}

class Developer {
    let name: String
    let leftSpoon: Spoon
    let rightSpoon: Spoon

    init(name: String, leftSpoon: Spoon, rightSpoon: Spoon) {
        self.name = name
        self.leftSpoon = leftSpoon
        self.rightSpoon = rightSpoon
    }

    func think() {
        if leftSpoon.index < rightSpoon.index {
            leftSpoon.pickUp()
            print("\(name) picked up Left Spoon")
        } else {
            rightSpoon.pickUp()
            print("\(name) picked up Right Spoon")
        }
        return
    }

    func eat() {
        print("\(name) has started eating...")
        usleep(UInt32(Int.random(in: 1 ... 1000)))
        leftSpoon.putDown()
        rightSpoon.putDown()
        print("\(name) has finished eating...")
    }

    func run() {
        while true {
            think()
            eat()
        }
    }
}

let spoon1 = Spoon(index: 1)
let spoon2 = Spoon(index: 2)
let spoon3 = Spoon(index: 3)
let spoon4 = Spoon(index: 4)
let spoon5 = Spoon(index: 5)

let dev1 = Developer(name: "Michael", leftSpoon: spoon1, rightSpoon: spoon2)
let dev2 = Developer(name: "Willy", leftSpoon: spoon2, rightSpoon: spoon3)
let dev3 = Developer(name: "Spencer", leftSpoon: spoon3, rightSpoon: spoon4)
let dev4 = Developer(name: "Ben", leftSpoon: spoon4, rightSpoon: spoon5)
let dev5 = Developer(name: "Josh", leftSpoon: spoon5, rightSpoon: spoon1)

let table = [dev1, dev2, dev3, dev4, dev5]

DispatchQueue.concurrentPerform(iterations: 5) { table[$0].run() }
 
*/

//Chandy/Misra Solution

let numberOfDevelopers = 5

struct ForkPair {
    static let forksSemaphore: [DispatchSemaphore] = Array(repeating: DispatchSemaphore(value: 1), count: numberOfDevelopers)
    
    let leftFork: DispatchSemaphore
    let rightFork: DispatchSemaphore
    
    init(leftIndex: Int, rightIndex: Int) {
        if leftIndex > rightIndex {
            leftFork = ForkPair.forksSemaphore[leftIndex]
            rightFork = ForkPair.forksSemaphore[rightIndex]
        } else {
            leftFork = ForkPair.forksSemaphore[rightIndex]
            rightFork = ForkPair.forksSemaphore[leftIndex]
        }
    }
    
    func pickUp() {
            leftFork.wait()
            rightFork.wait()
        }

        func putDown() {
            leftFork.signal()
            rightFork.signal()
        }
    }

    struct Developers {
        let forkPair: ForkPair
        let developerIndex: Int

        var leftIndex = -1
        var rightIndex = -1

        init(developerIndex: Int) {
            leftIndex = developerIndex
            rightIndex = developerIndex - 1

            if rightIndex < 0 {
                rightIndex += numberOfDevelopers
            }

            self.forkPair = ForkPair(leftIndex: leftIndex, rightIndex: rightIndex)
            self.developerIndex = developerIndex

            print("Developer: \(developerIndex)  left: \(leftIndex)  right: \(rightIndex)")
        }

        func run() {
            while true {
                print("Starting lock for Developer: \(developerIndex) Left:\(leftIndex) Right:\(rightIndex)")
                forkPair.pickUp()
                print("Start Eating Developer: \(developerIndex)")
                sleep(10)
                print("Ending lock forDeveloper: \(developerIndex) Left:\(leftIndex) Right:\(rightIndex)")
                forkPair.putDown()
            }
        }
    }

    let globalSemaphore = DispatchSemaphore(value: 0)

    for i in 0..<numberOfDevelopers {
            DispatchQueue.global(qos: .background).async {
                let p = Developers(developerIndex: i)

                p.run()
        }
    }

    for semaphore in ForkPair.forksSemaphore {
        semaphore.signal()
    }

    globalSemaphore.wait()
