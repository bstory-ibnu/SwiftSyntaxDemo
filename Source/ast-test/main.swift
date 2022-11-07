import SwiftSyntax
import Foundation

do {
    let file = URL(fileURLWithPath: "Source/ast-test/main.swift")
    let tree = try SyntaxParser.parse(file)
    let visitor = PerformFinder()
    visitor.walk(tree)
    print(visitor.functions)
} catch {
    print("failed")
}

func testFunction() {

}

class testClass {
    // Perform
    func testFunctionInClass() {

    }
}


