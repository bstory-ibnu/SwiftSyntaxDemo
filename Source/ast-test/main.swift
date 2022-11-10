import SwiftSyntax
import Foundation

do {
    let file = URL(fileURLWithPath: "Source/ast-test/TestClass.swift")
    let tree = try SyntaxParser.parse(file)
    let rewriter = PerformWriter()
    let newTree = rewriter.visit(tree)
    try "\(newTree)".write(to: file, atomically: true, encoding: .utf8)
    
} catch {
    print("failed")
}
