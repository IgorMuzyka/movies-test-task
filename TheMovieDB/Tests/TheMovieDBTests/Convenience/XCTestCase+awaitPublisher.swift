
import Combine
import XCTest

extension XCTestCase {
    /// borrowed from [here](https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/)
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        let cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            } receiveValue: { value in
                result = .success(value)
            }
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        return try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        ).get()
    }
}
