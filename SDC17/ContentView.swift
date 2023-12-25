import SwiftUI
import Foundation
import NSTask
import NSTaskBridge
import FluidGradient

struct ContentView: View {
    @State private var connectionResult: String? = nil
    @ViewBuilder func Line2(_ str: String) -> some View {
        HStack {
            Text(str)
                .font(.system(size: 7, design: .monospaced))
            Spacer()
        }
    }
    @ObservedObject var c = Console2.shared
    let consoleInstance = Console2()
    let deviceHeight = UIScreen.main.bounds.height
    let deviceWidth = UIScreen.main.bounds.width
    @AppStorage("rootmode") var root: Bool = false
    @State private var tinj: Bool = false
    @State private var spdr: Bool = false
    @State private var debu: Bool = false
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.blue, .black, .green],
                          highlights: [.blue ,.purple],
                          speed: 0.3,
                          blur: 0.75)
            .background(.quaternary)
            .ignoresSafeArea()
            VStack {
                Text("SparkHub")
                    .font(.title)
                    .foregroundColor(.primary)
                Spacer().frame(height: 20)
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(0..<c.lines.count, id: \.self) { i in
                                let item = c.lines[i]
                                Line2(item)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                    }
                    .frame(width: deviceWidth / 2, height: deviceHeight / 4)
                    
                    .opacity(0.8)
                    .padding(.horizontal)
                }
                .padding()
                .transition(.scale(scale: 1.0))
                .frame(width: deviceWidth / 2, height: deviceHeight / 4)
                .background(Color.black)
                .cornerRadius(10)
                .opacity(0.9)
                Spacer().frame(height: 75)
                Rectangle()
                    .frame(width: deviceWidth / 1.5, height: deviceHeight / 4)
                    .cornerRadius(25)
                    .foregroundColor(.black)
                    .cornerRadius(0.9)
                    .overlay {
                        List {
                            Section {
                                Toggle(isOn: $root) {
                                    Text("launch as root")
                                }
                                Toggle(isOn: $tinj) {
                                    Text("inject tweaks")
                                }
                            }
                            .disabled(debu)
                            Section {
                                Button(spdr ? "restart sparkd" : "start sparkd") {
                                    startsparkd(root: root)
                                }
                                .onAppear {
                                    let pid = (findPID(forProcessName: "sparkd") ?? 1)
                                    if pid != 1 {
                                        spdr = true
                                        Console2.shared.log("[*] sparkd is allready running with pid: " + String(pid))
                                    } else {
                                        spdr = false
                                    }
                                }
                                .disabled(debu)
                            }
                            Section(header: Text("Credits")) {
                                HStack {
                                    Image("main")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(380)
                                    Spacer()
                                    VStack {
                                        Text("SparkleChan")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("co-dev of FRMv2")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Image("sean")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(380)
                                    Spacer()
                                    VStack {
                                        Text("SeanIsTethered")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("lead dev of FRMv2")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Image("linushenze")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(380)
                                    Spacer()
                                    VStack {
                                        Text("Linus Henze")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("idownloadd code")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: deviceWidth / 1.5, height: deviceHeight / 3)
                        .cornerRadius(25)
                        .listStyle(GroupedListStyle())
                    }
                /*Button(action: {
                 startsparkd(root: root)
                 }) {
                 Text("start sparkd")
                 .font(.headline)
                 .padding()
                 .background(Color.green)
                 .foregroundColor(.white)
                 .cornerRadius(10)
                 }*/
            }
            .padding()
        }
    }
    func startsparkd(root: Bool) {
        debu = true
        if root == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Console2.shared.log("[+] killing sparkd if its running")
                runExecutable(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/usr/bin/killall sparkd")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Console2.shared.log("[+] starting sparkd")
                    runExecutableWithoutWaiting(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/usr/bin/bash /var/jb/basebin/sparklaunch.sh")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        Console2.shared.log("[+] sparkd launched with pid: " + String((findPID(forProcessName: "sparkd") ?? 1)))
                        debu = false
                        chck()
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Console2.shared.log("[+] killing sparkd if its running")
                runExecutable(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/usr/bin/killall sparkd")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Console2.shared.log("[+] starting sparkd")
                    runExecutableWithoutWaiting(pathAndArgs: "/var/jb/usr/bin/bash /var/jb/basebin/sparklaunch.sh")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        Console2.shared.log("[+] sparkd launched with pid: " + String((findPID(forProcessName: "sparkd") ?? 1)))
                        debu = false
                        chck()
                    }
                }
            }
        }
    }
    func chck() {
        if (findPID(forProcessName: "sparkd") ?? 1) != 1 {
            spdr = true
        } else {
            spdr = false
        }
    }
}
public func inject() {
    let music = String(findPID(forProcessName: "Music") ?? 1)
    let filza = String(findPID(forProcessName: "Filza") ?? 1)
    Console2.shared.log("[*] Apple Music pid: " + music)
    Console2.shared.log("[*] Filza pid: " + filza)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        Console2.shared.log("[*] injecting dependencies")
        runExecutableWithoutWaiting(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/basebin/opainject " + music + " /var/jb/inj/inj.dylib")
        runExecutableWithoutWaiting(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/basebin/opainject " + filza + " /var/jb/inj/inj.dylib")
        Console2.shared.log("[+] injected dependencies")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Console2.shared.log("[*] injecting tweaks")
            runExecutableWithoutWaiting(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/basebin/opainject " + music + " /var/jb/inj/af.dylib")
            runExecutableWithoutWaiting(pathAndArgs: "/var/jb/usr/bin/sudo /var/jb/basebin/opainject " + filza + " /var/jb/inj/csk.dylib")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                Console2.shared.log("[+] tweaks injected")
            }
        }
    }
}
func executePSCommand() -> String? {
    let process = NSTask()
    process.executableURL = URL(fileURLWithPath: "/var/jb/usr/bin/sudo")
    process.arguments = ["/bin/ps","-e", "-o", "pid,comm"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}
import Foundation

func findPID(forProcessName processName: String) -> Int? {
    let process = NSTask()
    process.executableURL = URL(fileURLWithPath: "/var/jb/usr/bin/sudo")
    process.arguments = ["/bin/ps","-e", "-o", "pid,comm"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let outputString = String(data: data, encoding: .utf8) else {
        return nil
    }

    let lines = outputString.components(separatedBy: "\n")
    for line in lines.dropFirst() { // Skip the header line
        let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        if components.count >= 2 {
            let pidString = components[0].trimmingCharacters(in: .whitespaces)
            if let pid = Int(pidString) {
                let processPath = components[1...].joined(separator: " ")
                let processNameComponents = processPath.components(separatedBy: "/")
                let lastPathComponent = processNameComponents.last ?? ""

                if lastPathComponent == processName {
                    return pid
                }
            }
        }
    }

    return nil
}
func runExecutable(pathAndArgs: String) {
    var workdir = "/var/containers"
    var components = pathAndArgs.components(separatedBy: " ")
    guard let executable = components.first, !executable.isEmpty else {
        return
    }

    components.removeFirst()
    let task = NSTask()

    task.currentDirectoryURL = URL(fileURLWithPath: workdir)
    task.executableURL = URL(fileURLWithPath: executable)
    task.arguments = components

    let pipe = Pipe()
    task.standardError = pipe
    task.standardOutput = pipe

    do {
        //outputText = ""
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        // Attempt to decode as ASCII
        if let asciiString = String(data: data, encoding: .ascii) {
            //console.log(asciiString)
            //outputText = asciiString
        } else {
            // Fallback to UTF-8
            if let utf8String = String(data: data, encoding: .utf8) {
                Console2.shared.log(utf8String)
                //outputText = utf8String
            }
        }
    } catch {
        return
    }
}
func runExecutableWithoutWaiting(pathAndArgs: String) {
    let workdir = "/var/containers"
    var components = pathAndArgs.components(separatedBy: " ")

    guard let executable = components.first, !executable.isEmpty else {
        return
    }

    components.removeFirst()

    let task = NSTask()
    task.currentDirectoryURL = URL(fileURLWithPath: workdir)
    task.executableURL = URL(fileURLWithPath: executable)
    task.arguments = components

    let pipe = Pipe()
    task.standardError = pipe
    task.standardOutput = pipe

    do {
        task.launch()
        
        // Detach the process from the current terminal session
        if setsid() == -1 {
            print("Error detaching process from terminal.")
        }

        // Close standard input, output, and error file handles if needed
        // task.standardInput = nil
        // task.standardOutput = nil
        // task.standardError = nil

        // You may handle the process asynchronously here if needed
        // For example, you might set up a completion handler or use NotificationCenter

    } catch {
        // Handle launch errors if needed
        return
    }
}
class Console2: ObservableObject {
    
    static let shared = Console2()
    
    @Published var lines = [String]()
    
    @AppStorage("bstrp") var selectedSegment = 0
    @AppStorage("rie") var respring_in_end: Bool = true
    @AppStorage("rfs") var restorerfs: Bool = true
    
    init() {
        log("[*] SparkHub")
        log("[*] Codename: Christmas Troll")
        log("[*] Bootstrap using FRM 0.2.2 or higher")
    }
    public func log(_ str: String) {
        withAnimation {
            self.lines.append(str)
        }
    }
    public func log2(_ str: String) {
        self.lines.append(str)
    }
    public func clean() {
        self.lines = [""]
    }
    public func appendCharacterToLatestLine(_ character: Character) {
        // Check if there are any lines in the array
        guard var latestLine = self.lines.last else {
            // If there are no lines, create a new line with the character
            self.lines.append(String(character))
            return
        }
        
        // Append the character to the latest line
        latestLine.append(character)
        
        // Update the last line in the array
        self.lines[self.lines.count - 1] = latestLine
    }
}
