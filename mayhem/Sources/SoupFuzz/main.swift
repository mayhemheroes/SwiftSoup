#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#elseif canImport(MSVCRT)
import MSVCRT
#endif

import Foundation
import SwiftSoup

@_cdecl("LLVMFuzzerTestOneInput")
public func SoupFuzz(_ start: UnsafeRawPointer, _ count: Int) -> CInt {
    let fdp = FuzzedDataProvider(start, count)
    do {
        if let cleanstr = try SwiftSoup.clean(fdp.ConsumeRandomLengthString(), Whitelist.basic()) {
            let doc: Document = try SwiftSoup.parse(cleanstr)
            let choice = fdp.ConsumeIntegralInRange(from: 0, to: 1)
            switch (choice) {
            case 0:
                try doc.text()
            case 1:
                try doc.select(fdp.ConsumeRandomLengthString()).first()
            default:
                try doc.select(fdp.ConsumeRandomLengthString()).attr(fdp.ConsumeRandomLengthString(), fdp.ConsumeRandomLengthString())
            }
        }
    }
    catch Exception.Error(let _, let _) {
        return -1
    }
    catch let error {
        print(error)
        print(type(of: error))
        exit(EXIT_FAILURE)
    }
    return 0;
}