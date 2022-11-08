import SwiftSyntax
import Foundation

do {
    TestPerform()
    
    let file = URL(fileURLWithPath: "Source/ast-test/TestClass.swift")
    let tree = try SyntaxParser.parse(file)
//    let visitor = PerformFinder()
    let rewriter = PerformWriter()
    let newTree = rewriter.visit(tree)
    try "\(newTree)".write(to: file, atomically: true, encoding: .utf8)
    
} catch {
    print("failed")
}
