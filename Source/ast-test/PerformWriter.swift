//
//  File.swift
//  
//
//  Created by ibnu.sina on 07/11/22.
//

import SwiftSyntax
import Foundation

class PerformWriter: SyntaxRewriter {
    let performMark = "// Perform"
    
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        let newNode = SyntaxFactory.addPerform(node)
        return DeclSyntax(newNode)
    }
    
    
}
