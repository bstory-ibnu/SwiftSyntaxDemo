# SwiftSyntaxDemo

## Development Environment

XCode 13.2.1

## How To Run

You will not need XCode or text editor to run this demo. 
Run below command, at downloaded repository folder
```
swift build;swift run
```

The demo will modify TestClas.swift content from
```
import Foundation

class TestClass {
    // Perform
    func testFunc(a: String) -> String {
        var i = 1
        var b = 3
        return "result"
    }
    
}
```

to 
```
import Foundation

class TestClass {
    
    func testFunc(a: String, callerFunction: String = #function, callerFile: String = #file) -> String {
        return Measure(at: Self) {
        	var i = 1
        	var b = 3
        	return "result"
        }
    }
    
}
```

`return` Statement is optional you can test TestClass.swift with below content then re-run `swift build;swift run`
```
import Foundation

class TestClass {
    // Perform
    func testFunc(a: String) {
        var i = 1
        var b = 3
    }
    
}
```
