//
//  File.swift
//  
//
//  Created by ibnu.sina on 08/11/22.
//

import Foundation
import SwiftSyntax

extension SyntaxFactory {
    private static var performMark: String { "// Perform" }
    
    
    public static func addPerform(_ node: FunctionDeclSyntax) -> FunctionDeclSyntax {
        let trivia = node.leadingTrivia?.filter({ piece in
            if case let TriviaPiece.lineComment(comment) = piece, comment == performMark {
                return false
            }
            return true
        })
        
        if trivia?.count == node.leadingTrivia?.count {
            return node
        }
        
        
        var newNode = node
        
        newNode = node.withLeadingTrivia(Trivia(pieces: trivia ?? []))
        newNode = newNode.withSignature(funcSign(node: node))
        
        return newNode
    }
    
    
    private static func paramSyntax(leadingComma: Bool = false) -> FunctionParameterSyntax {
        let param = makeFunctionParameter(
            attributes: nil,
            firstName: nil,
            secondName: makeStringLiteral("callerFile"),
            colon: makeColonToken(),
            type: makeTypeIdentifier("String", leadingTrivia: Trivia.spaces(1), trailingTrivia: Trivia.spaces(1)),
            ellipsis: nil,
            defaultArgument: makeInitializerClause(
                equal: makeEqualToken().withTrailingTrivia(Trivia.spaces(1)),
                value: ExprSyntax(makePoundFileExpr(poundFile: makePoundFileKeyword()))),
            trailingComma: nil)
        return param
    }
    
    private static func funcSign(node: FunctionDeclSyntax) -> FunctionSignatureSyntax {
        var newParamList = node.signature.input.parameterList
        if var lastParam = newParamList.last {
            lastParam = lastParam.withTrailingComma(makeCommaToken().withTrailingTrivia(Trivia.spaces(1)))
            newParamList = newParamList.removingLast()
            newParamList = newParamList.appending(lastParam)
        }
        
        newParamList = newParamList.appending(paramSyntax())
        let sign = makeFunctionSignature(
            input: makeParameterClause(
                leftParen: node.signature.input.leftParen,
                parameterList: newParamList,
                rightParen: node.signature.input.rightParen),
            asyncOrReasyncKeyword: node.signature.asyncOrReasyncKeyword,
            throwsOrRethrowsKeyword: node.signature.throwsOrRethrowsKeyword,
            output: node.signature.output
        )
        return sign
    }
}
