/*
 * Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
import Foundation

private struct XCTestObservations {
  var testsuites: XMLElement? = XMLElement(name: "testsuites")
  var testsuite: XMLElement?
  var testcase: XMLElement?
}

private class XCTestObserver: NSObject {
  var collection: XCTestObservations

  init(collecting at: XCTestObservations) {
    self.collection = at
  }
}

extension XCTestObserver: XCTestObservation {
  public func testBundleWillStart(_ testBundle: Bundle) {
  }

  public func testSuiteWillStart(_ testSuite: XCTestSuite) {
    collection.testsuite = XMLElement(name: "testsuite")
  }

  public func testCaseWillStart(_ testCase: XCTestCase) {
    collection.testcase = XMLElement(name: "testcase")
  }

  public func testCase(_ testCase: XCTestCase,
                       didFailWithDescription description: String,
                       inFile filePath: String?, atLine lineNumber: Int) {
    collection.testcase?.setAttributesWith([
      "name": testCase.name,
      "failure": description
    ])

    if let testcase = collection.testcase {
      collection.testsuite?.addChild(testcase)
    }
    collection.testcase = nil
  }

  public func testCaseDidFinish(_ testCase: XCTestCase) {
    collection.testcase?.setAttributesWith([
      "name": testCase.name,
      "classname": NSStringFromClass(type(of: testCase.self)),
      "time": String(format: "%g", testCase.testRun?.testDuration ?? 0.0)
    ])

    if let testcase = collection.testcase {
      collection.testsuite?.addChild(testcase)
    }
    collection.testcase = nil
  }

  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    guard let run = testSuite.testRun as? XCTestSuiteRun else { return }

    collection.testsuite?.setAttributesWith([
      "name": testSuite.name,
      "tests": String(format: "%u", testSuite.testCaseCount),
      "errors": String(format: "%u", run.unexpectedExceptionCount),
      "failures": String(format: "%u", run.failureCount),
      "skipped": String(format: "%u", 0),
      "time": String(format: "%g", run.testDuration)
    ])

    if let testsuite = collection.testsuite {
      collection.testsuites?.addChild(testsuite)
    }
    collection.testsuite = nil
  }

  public func testBundleDidFinish(_ testBundle: Bundle) {
  }
}

public class JUnitFormatter {
  public static let shared: JUnitFormatter = JUnitFormatter()

  private var observations: XCTestObservations
  private var observer: XCTestObserver

  public init() {
    observations = XCTestObservations()
    observer = XCTestObserver(collecting: observations)
  }

  public func inject() {
    XCTestObservationCenter.shared.addTestObserver(observer)
  }

  public func eject() {
    XCTestObservationCenter.shared.removeTestObserver(observer)
  }

  public func write(to path: String) {
    if let testsuites = observations.testsuites {
      let document: XMLDocument = XMLDocument(rootElement: testsuites)
      if let data = String(data: document.xmlData, encoding: .utf8) {
        print(data)
      }
    }
  }
}
