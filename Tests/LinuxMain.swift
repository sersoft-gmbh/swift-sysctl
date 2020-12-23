import XCTest

import SysctlTests

var tests = [XCTestCaseEntry]()
tests += SysctlTests.__allTests()

XCTMain(tests)
