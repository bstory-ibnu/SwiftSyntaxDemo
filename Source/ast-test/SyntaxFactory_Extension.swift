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
        newNode = newNode.withBody(funcContent(node: node))
        
        return newNode
    }
    
    
    private static func callerFileParam() -> FunctionParameterSyntax {
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
    
    private static func callerFunctionParam() -> FunctionParameterSyntax {
        let param = makeFunctionParameter(
            attributes: nil,
            firstName: nil,
            secondName: makeStringLiteral("callerFunction"),
            colon: makeColonToken(),
            type: makeTypeIdentifier("String", leadingTrivia: Trivia.spaces(1), trailingTrivia: Trivia.spaces(1)),
            ellipsis: nil,
            defaultArgument: makeInitializerClause(
                equal: makeEqualToken().withTrailingTrivia(Trivia.spaces(1)),
                value: ExprSyntax(makePoundFunctionExpr(poundFunction: makePoundFunctionKeyword()))),
            trailingComma: makeCommaToken().withTrailingTrivia(.spaces(1)))
        return param
    }
    
    private static func funcSign(node: FunctionDeclSyntax) -> FunctionSignatureSyntax {
        var newParamList = node.signature.input.parameterList
        if var lastParam = newParamList.last {
            lastParam = lastParam.withTrailingComma(makeCommaToken().withTrailingTrivia(Trivia.spaces(1)))
            newParamList = newParamList.removingLast()
            newParamList = newParamList.appending(lastParam)
        }
        
        newParamList = newParamList.appending(callerFunctionParam())
        newParamList = newParamList.appending(callerFileParam())
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
    
    private static func funcContent(node: FunctionDeclSyntax) -> CodeBlockSyntax? {
        guard let oldContent = node.body?.statements,
              let leadingTrivia = oldContent.first?.leadingTrivia
        else {
            return node.body
        }
        
        let children = oldContent.children.map { syntax -> CodeBlockItemSyntax in
            if let leading = syntax.leadingTrivia {
                return makeCodeBlockItem(item: syntax.withLeadingTrivia(leading.appending(TriviaPiece.tabs(1))), semicolon: nil, errorTokens: nil)
            }
            return  makeCodeBlockItem(item: syntax, semicolon: nil, errorTokens: nil)
        }
        
        let newContent = makeCodeBlockItemList(children)
        
        let closure = makeClosureExpr(
            leftBrace: makeLeftBraceToken(),
            signature: nil,
            statements: newContent,
            rightBrace: makeRightBraceToken().withLeadingTrivia(leadingTrivia)
        )
        
        let funcCall = makeFunctionCallExpr(
            calledExpression: ExprSyntax(makeIdentifierExpr(identifier: makeIdentifier("Measure "), declNameArguments: nil)),
            leftParen: nil,
            argumentList: makeTupleExprElementList([]),
            rightParen: nil,
            trailingClosure: closure,
            additionalTrailingClosures: nil).withLeadingTrivia(leadingTrivia)
        
        let newStatements = makeCodeBlockItemList([
            makeCodeBlockItem(item: Syntax(funcCall), semicolon: nil, errorTokens: nil)
        ])
        
        let newBody = node.body?.withStatements(newStatements)
        
        
        return newBody
    }
    
    
}

extension Trivia {
    static func newLine(indented: Int) -> Trivia {
        let tab = TriviaPiece.tabs(indented)
        return .init(arrayLiteral: .newlines(1), tab)
    }
}
