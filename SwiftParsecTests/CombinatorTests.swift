//
//  CombinatorTests.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-26.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class CombinatorTests: XCTestCase {
    
    func testChoice() {
        
        let digit = StringParser.digit
        let letter = StringParser.letter
        let space = StringParser.space
        
        let parsers = [digit, letter, space]
        let choice = StringParser.choice(parsers)
        
        // Test for success.
        let matching = ["1a ", "a1 ", " 1a"]
        
        let errorMessage = "GenericParser.choice error."
        
        testStringParserSuccess(choice, inputs: matching) { input, result in
            
            let isMatch = input.hasPrefix(String(result))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["", ";1 a", "+a 1"]
        let shouldFailMessage = "GenericParser.choice should have failed."
        
        testStringParserFailure(choice, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testOtherwise() {
        
        let otherwiseDigit: Character = "0"
        let digit = StringParser.digit.otherwise(otherwiseDigit)
        
        // Test for success.
        let matchingDigit = ["1a ", "a1 ", " 1a"]
        
        let errorMessage = "GenericParser.otherwise error."
        
        testStringParserSuccess(digit, inputs: matchingDigit) { input, result in
            
            let isMatch = input.hasPrefix(String(result)) || result == otherwiseDigit
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let otherwiseString = "xyz"
        let string = StringParser.string("abc").otherwise(otherwiseString)
        
        let matchingString = ["abc", "123"]
        
        testStringParserSuccess(string, inputs: matchingString) { input, result in
            
            let isMatch = input.hasPrefix(result) || result == otherwiseString
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["ab1", "a12"]
        let shouldFailMessage = "GenericParser.otherwise should have failed."
        
        testStringParserFailure(string, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testOptional() {
        
        let optionalDigit = StringParser.digit.optional
        
        // Test for success.
        let matchingDigit = ["1a ", "a1 ", " 1a"]
        
        let errorMessage = "GenericParser.optional error."
        
        testStringParserSuccess(optionalDigit, inputs: matchingDigit) { input, result in
            
            let isMatch = result == nil || input.hasPrefix(String(result!))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let optionalString = StringParser.string("abc").optional
        
        let matchingString = ["abc", "123"]
        
        testStringParserSuccess(optionalString, inputs: matchingString) { input, result in
            
            let isMatch = result == nil || input.hasPrefix(result!)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["ab1", "a12"]
        let shouldFailMessage = "GenericParser.optional should have failed."
        
        testStringParserFailure(optionalString, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testDiscard() {
        
        // Test for success.
        let discardDigit = StringParser.digit.discard
        let matchingDigit = ["1a", "2b", "3c"]
        testStringParserSuccess(discardDigit, inputs: matchingDigit) { _, _ in true }
        
        let discardString = StringParser.string("abc").discard
        let matchingString = ["abc", "abc123"]
        testStringParserSuccess(discardString, inputs: matchingString) { _, _ in true }
        
        // Test when not matching.
        let notMatching = ["ab1", "a12"]
        let shouldFailMessage = "GenericParser.discard should have failed."
        
        testStringParserFailure(discardString, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testBetween() {
        
        let digitOpening = StringParser.character("(")
        let digitClosing = StringParser.character(")")
        let digit = StringParser.digit.between(digitOpening, digitClosing)
        
        // Test for success.
        let matchingDigit = ["(1) ", "(2)adsf", "(3)xfsa"]
        
        let errorMessage = "GenericParser.between error."
        
        testStringParserSuccess(digit, inputs: matchingDigit) { inputStr, result in
            
            var input = inputStr
            input.popFirst()
            
            let isMatch = input.hasPrefix(String(result))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: inputStr, result: result))
            
        }
        
        let stringOpening = StringParser.string("{[(")
        let stringClosing = StringParser.string(")]}")
        let string = StringParser.string("abc").between(stringOpening, stringClosing)
        
        let matchingString = ["{[(abc)]}", "{[(abc)]}abc"]
        
        testStringParserSuccess(string, inputs: matchingString) { inputStr, result in
            
            let startIndex = inputStr.startIndex
            
            var input = inputStr
            input.removeRange(startIndex...startIndex.advancedBy(2))
            
            let isMatch = input.hasPrefix(result)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: inputStr, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["{[(ab)]}", "{[(abc)]", "[(abc)]}"]
        let shouldFailMessage = "GenericParser.between should have failed."
        
        testStringParserFailure(string, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testSkipMany1() {
        
        let skipMany1 = StringParser.string("asdf").skipMany1
        
        // Test for success.
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf"]
        
        testStringParserSuccess(skipMany1, inputs: matching) { _, _ in true }
        
        // Test when not matching.
        let notMatching = ["asd", "asdfasd", "xasdf"]
        let shouldFailMessage = "GenericParser.skipMany1 should have failed."
        
        testStringParserFailure(skipMany1, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testMany1() {
        
        let manyString = StringParser.string("asdf").many1
        
        // Test for success.
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf"]
        let errorMessage = "GenericParser.many1 error."
        
        testStringParserSuccess(manyString, inputs: matching) { input, result in
            
            let isMatch = input == result.joinWithSeparator("")
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["asd", "asdfasd", "xasdf"]
        let shouldFailMessage = "GenericParser.many1 should have failed."
        
        testStringParserFailure(manyString, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testSeparatedBy() {
        
        let separator: Character = ","
        
        let comma = StringParser.character(separator)
        let letters = StringParser.letter.many1.stringValue
        let commaSeparated = letters.separatedBy(comma)
        
        // Test for success.
        let matching = ["adsf", "asd,fasdÀf,qeàwr,dÉgéh", "234,adsf,erty", ",adsf,zsdf"]
        
        let errorMessage = "GenericParser.separatedBy error."
        
        testStringParserSuccess(commaSeparated, inputs: matching) { input, result in
            
            let isMatch = result.isEmpty || result == input.componentsSeparatedByString(String(separator))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["asd,,", "adsf,wert,1"]
        let shouldFailMessage = "GenericParser.separatedBy should have failed."
        
        testStringParserFailure(commaSeparated, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testSeparatedBy1() {
        
        let separator: Character = ","
        
        let comma = StringParser.character(separator)
        let letters = StringParser.letter.many1.stringValue
        let commaSeparated = letters.separatedBy1(comma)
        
        // Test for success.
        let matching = ["adsf", "asd,fasdÀf,qeàwr,dÉgéh", "adsf,zsdf"]
        
        let errorMessage = "GenericParser.separatedBy1 error."
        
        testStringParserSuccess(commaSeparated, inputs: matching) { input, result in
            
            let isMatch = result == input.componentsSeparatedByString(String(separator))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["asd,,", "adsf,wert,1", "234,adsf,erty", ",adsf,zsdf"]
        let shouldFailMessage = "GenericParser.separatedBy1 should have failed."
        
        testStringParserFailure(commaSeparated, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testDividedBy() {
        
        let separator: Character = ","
        
        let comma = StringParser.character(separator)
        let letters = StringParser.letter.many1.stringValue
        let commaSeparated = letters.dividedBy(comma) <* StringParser.eof
        
        let errorMessage = "GenericParser.dividedBy error."
        
        // End separator required.
        let endRequired = ["adsf,", "asd,fasdÀf,qeàwr,dÉgéh,"]
        
        testStringParserSuccess(commaSeparated, inputs: endRequired) { input, result in
            
            let isMatch = result.isEmpty || result + [""] == input.componentsSeparatedByString(String(separator))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // End separator not required
        let commaDivided = letters.dividedBy(comma, endSeparatorRequired: false) <* StringParser.eof
        
        let endNotRequired = ["adsf,", "asd,fasdÀf,qeàwr,dÉgéh,", "adsf", "asd,fasdÀf,qeàwr,dÉgéh"]
        
        testStringParserSuccess(commaDivided, inputs: endNotRequired) { input, result in
            
            let isEmpty = result.isEmpty
            let endNotPresentEqual = result == input.componentsSeparatedByString(String(separator))
            let endPresentEqual = result + [""] == input.componentsSeparatedByString(String(separator))
            
            let isMatch = isEmpty || endNotPresentEqual || endPresentEqual
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["adsf,wert,werb", "234,adsf,erty,", ",adsf,zsdf,"]
        let shouldFailMessage = "GenericParser.dividedBy should have failed."
        
        testStringParserFailure(commaSeparated, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testDividedBy1() {
        
        let separator: Character = ","
        
        let comma = StringParser.character(separator)
        let letters = StringParser.letter.many1.stringValue
        let commaSeparated = letters.dividedBy1(comma)
        
        let errorMessage = "GenericParser.dividedBy1 error."
        
        // End separator required.
        let endRequired = ["adsf,", "asd,fasdÀf,qeàwr,dÉgéh,"]
        
        testStringParserSuccess(commaSeparated, inputs: endRequired) { input, result in
            
            let isMatch = result + [""] == input.componentsSeparatedByString(String(separator))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // End separator not required
        let commaDivided = letters.dividedBy1(comma, endSeparatorRequired: false)
        
        let endNotRequired = ["adsf,", "asd,fasdÀf,qeàwr,dÉgéh,", "adsf", "asd,fasdÀf,qeàwr,dÉgéh"]
        
        testStringParserSuccess(commaDivided, inputs: endNotRequired) { input, result in
            
            let endNotPresentEqual = result == input.componentsSeparatedByString(String(separator))
            let endPresentEqual = result + [""] == input.componentsSeparatedByString(String(separator))
            
            let isMatch = endNotPresentEqual || endPresentEqual
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["adsf,wert,werb", ",adsf,zsdf,", "234,adsf,erty,"]
        let shouldFailMessage = "GenericParser.dividedBy1 should have failed."
        
        testStringParserFailure(commaSeparated, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testCount() {
        
        let errorMessage = "GenericParser.count error."
        
        let countNumber = 3
        let letters = StringParser.letter.many.stringValue.count(countNumber)
        
        // Test for success.
        let matching = ["adsf", "aÉaàa1"]
        
        testStringParserSuccess(letters, inputs: matching) { input, result in
            
            let sameCount = result.count == countNumber
            let joinedResult = result.joinWithSeparator("")
            
            let isMatch = sameCount && input.hasPrefix(joinedResult)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let asdf = StringParser.string("asdf").count(countNumber)
        let matchingAsdf = ["asdfasdfasdf"]
        
        testStringParserSuccess(asdf, inputs: matchingAsdf) { input, result in
            
            let sameCount = result.count == countNumber
            let joinedResult = result.joinWithSeparator("")
            
            let isMatch = sameCount && input.hasPrefix(joinedResult)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatchingAsdf = ["asd1", "asdfasdfasd1", "1asdf", "asdf"]
        let shouldFailMessage = "GenericParser.count should have failed."
        
        testStringParserFailure(asdf, inputs: notMatchingAsdf) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testChainRight() {
        
        let digits = StringParser.digit.many1.stringValue
        let dot = StringParser.character(".").stringValue
        let decimal = GenericParser.lift2(+, parser1: dot, parser2: digits)
        let double = GenericParser.lift2(+, parser1: digits, parser2: decimal).map { Double($0)! }
        
        let power: (Double, Double) -> Double = pow
        let expOp = StringParser.string("**") *> GenericParser(result: power)
        let exp = double.chainRight(expOp, otherwise: 0)
        
        // Test for success.
        let matching = ["2.0**2.0", "2.0**2.0aadsf", "2.0**3.0**3.0", "1.0", "a"]
        let expectedResult = [power(2, 2), power(2.0, 2.0), power(2.0, power(3.0, 3.0)), 1.0, 0]
        var index = 0
        
        let errorMessage = "GenericParser.chainRight error."
        
        testStringParserSuccess(exp, inputs: matching) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expectedResult[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["2.0**", "2.0**2.0*"]
        let shouldFailMessage = "GenericParser.chainRight should have failed."
        
        testStringParserFailure(exp, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testChainRight1() {
        
        let digits = StringParser.digit.many1.stringValue
        let dot = StringParser.character(".").stringValue
        let decimal = GenericParser.lift2(+, parser1: dot, parser2: digits)
        let double = GenericParser.lift2(+, parser1: digits, parser2: decimal).map { Double($0)! }
        
        let power: (Double, Double) -> Double = pow
        let expOp = StringParser.string("**") *> GenericParser(result: power)
        let exp = double.chainRight1(expOp)
        
        // Test for success.
        let matching = ["2.0**2.0", "2.0**2.0aadsf", "2.0**3.0**3.0", "1.0"]
        let expectedResult = [power(2, 2), power(2.0, 2.0), power(2.0, power(3.0, 3.0)), 1.0]
        var index = 0
        
        let errorMessage = "GenericParser.chainRight1 error."
        
        testStringParserSuccess(exp, inputs: matching) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expectedResult[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["2.0**", "2.0**2.0*", "a"]
        let shouldFailMessage = "GenericParser.chainRight1 should have failed."
        
        testStringParserFailure(exp, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testChainLeft() {
        
        let addOp: GenericParser<String, (), (Int, Int) -> Int> =
        StringParser.character("+") *> GenericParser(result: +) <|>
            StringParser.character("-") *> GenericParser(result: -)
        
        let integer = StringParser.digit.many1.stringValue.map { Int($0)! }
        
        let add = integer.chainLeft(addOp, otherwise: 0)
        
        // Test for success.
        let matchingAdd = ["1+2+3", "1-2-3", "1", "a"]
        let expectedResultAdd = [1 + 2 + 3, 1 - 2 - 3, 1, 0]
        
        var index = 0
        
        let errorMessage = "GenericParser.chainLeft error."
        
        testStringParserSuccess(add, inputs: matchingAdd) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expectedResultAdd[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let mulOp: GenericParser<String, (), (Int, Int) -> Int> =
        StringParser.character("*") *> GenericParser(result: *) <|>
            StringParser.character("/") *> GenericParser(result: /)
        
        let mul = integer.chainLeft(mulOp, otherwise: 0)
        
        let matchingMul = ["1*2*3", "16/2/4", "1", "a"]
        let expectedResultMul = [1 * 2 * 3, 16 / 2 / 4, 1, 0]
        
        index = 0
        
        testStringParserSuccess(mul, inputs: matchingMul) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expectedResultMul[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["2*", "2*2*"]
        let shouldFailMessage = "GenericParser.chainLeft should have failed."
        
        testStringParserFailure(mul, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testChainLeft1() {
        
        let addOp: GenericParser<String, (), (Int, Int) -> Int> =
        StringParser.character("+") *> GenericParser(result: +) <|>
            StringParser.character("-") *> GenericParser(result: -)
        
        let integer = StringParser.digit.many1.stringValue.map { Int($0)! }
        
        let add = integer.chainLeft1(addOp)
        
        // Test for success.
        let matchingAdd = ["1+2+3", "1-2-3", "1"]
        let expectedResultAdd = [1 + 2 + 3, 1 - 2 - 3, 1]
        
        var index = 0
        
        let errorMessage = "GenericParser.chainLeft1 error."
        
        testStringParserSuccess(add, inputs: matchingAdd) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expectedResultAdd[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let mulOp: GenericParser<String, (), (Int, Int) -> Int> =
        StringParser.character("*") *> GenericParser(result: *) <|>
            StringParser.character("/") *> GenericParser(result: /)
        
        let mul = integer.chainLeft1(mulOp)
        
        let matchingMul = ["1*2*3", "16/2/4", "1"]
        let expectedResultMul = [1 * 2 * 3, 16 / 2 / 4, 1]
        
        index = 0
        
        testStringParserSuccess(mul, inputs: matchingMul) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expectedResultMul[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["2*", "2*2*", "a"]
        let shouldFailMessage = "GenericParser.chainLeft1 should have failed."
        
        testStringParserFailure(mulOp, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testNoOccurence() {
        
        let alphaNum = StringParser.alphaNumeric
        let keyworkLet = StringParser.string("let") <* alphaNum.noOccurence
        
        // Test for success.
        let matching = ["let", "let;", "let "]
        
        let errorMessage = "GenericParser.noOccurence error."
        
        testStringParserSuccess(keyworkLet, inputs: matching) { input, result in
            
            let isMatch = input.hasPrefix(result)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["lets", "let2", "le", "a"]
        let shouldFailMessage = "GenericParser.noOccurence should have failed."
        
        testStringParserFailure(keyworkLet, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testManyTill() {
        
        let commentStartStr = "<!--"
        
        let anyChar = StringParser.anyCharacter
        let commentStart = StringParser.string(commentStartStr)
        let commentEnd = StringParser.string("-->")
        let comment = (commentStart *> anyChar.manyTill(commentEnd.attempt)).stringValue
        
        // Test for success.
        let matching = ["<!-- A comment -->", "<!-- Un autre en français -->", "<!---->"]
        
        let errorMessage = "GenericParser.manyTill error."
        
        testStringParserSuccess(comment, inputs: matching) { inputStr, result in
            
            let startIndex = inputStr.startIndex
            
            var input = inputStr
            input.removeRange(startIndex..<commentStartStr.endIndex)
            
            let isMatch = result.isEmpty || input.hasPrefix(result)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: inputStr, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["<!-- A comment ->", "<!-- Un autre en français", "<---->", "a"]
        let shouldFailMessage = "GenericParser.manyTill should have failed."
        
        testStringParserFailure(comment, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testRecursive() {
        
        let openingParen = StringParser.character("(")
        let closingParen = StringParser.character(")")
        
        let decimal = GenericTokenParser<()>.decimal
        
        let operators: GenericParser<String, (), (Int, Int) -> Int> =
        StringParser.character("+") *> GenericParser(result: +) <|>
            StringParser.character("-") *> GenericParser(result: -)
        
        let expression = GenericParser<String, (), Int>.recursive { expression in
            
            func opParser(left: Int) -> GenericParser<String, (), Int> {
                
                return operators >>- { f in
                    
                    expression >>- { right in
                        
                        opParser1(f(left, right))
                        
                    }
                    
                }
                
            }
            
            func opParser1(right: Int) -> GenericParser<String, (), Int> {
                
                return opParser(right) <|> GenericParser(result: right)
                
            }
            
            return expression.between(openingParen, closingParen) <|> decimal >>- { term in
                
                opParser(term) <|> GenericParser(result: term)
                
            }
            
        }
        
        let matching = ["3-(1+2)", "3-(1-(3+1))"]
        let expected = [3-(1+2), 3-(1-(3+1))]
        
        var index = 0
        
        let errorMessage = "GenericParser.recursive did not succeed."
        
        testStringParserSuccess(expression, inputs: matching) { input, result in
            
            defer { index += 1 }
            XCTAssertEqual(expected[index], result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testEof() {
        
        let eof = StringParser.eof
        
        // Test for success.
        let matching = [""]
        
        testStringParserSuccess(eof, inputs: matching) { _, _ in true }
        
        // Test when not matching.
        let notMatching = ["\n", "\r", "\n\r", "a"]
        let shouldFailMessage = "GenericParser.eof should have failed."
        
        testStringParserFailure(eof, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
}
