//
//  NetworkingTests.swift
//  SearchIOSAppTests
//
//  Created by Muhammad Usman Tatla on 12/12/21.
//

import XCTest
import Moya
import RxTest
import RxSwift

@testable import SearchIOSApp

class NetworkingTests: XCTestCase {
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func test_OnFetch_returnsConnectivtyErrorOnNon200HTTPResponses() {
        var expectations = [XCTestExpectation]()
        [199, 300, 400, 500].enumerated().forEach { index, code in
            let sut = makeSUT(for: code, data: anyData())
            let expectation = expectation(description: "Wait for async Code")
            sut.fetchUsers(search: "23", pageNumber: 1, pageSize: 12)
                .subscribe { _ in
                    XCTFail("Expected to fail with connectivity error")
                } onFailure: { error in
                    guard let error = error as? ApiError else {
                        XCTFail("Expected to fail with API Error connectivity error")
                        return
                    }
                    XCTAssertEqual(ApiError.connectivity, error)
                    expectation.fulfill()
                }
                .disposed(by: disposeBag)
            expectations.append(expectation)
            
        }
        wait(for: expectations, timeout: 1)
    }
    
    func test_OnFetch_returnsInValidDataErrorOnInValidDataHTTPResponses() {
        
        let invalidData = Data("Any invalid Data".utf8)
        let sut = makeSUT(for: 200, data: invalidData)
        let expectation = expectation(description: "Wait for async Code")
        sut.fetchUsers(search: "23", pageNumber: 1, pageSize: 12)
            .subscribe { _ in
                XCTFail("Expected to fail with connectivity error")
            } onFailure: { error in
                guard let error = error as? ApiError else {
                    XCTFail("Expected to fail with API Error invalidData error")
                    return
                }
                XCTAssertEqual(ApiError.invalidData, error)
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
    
    
    func test_OnFetch_returnsEmptyProfileModelArrayOnEmptyValidPResponses() {
        
        let sut = makeSUT(for: 200, data: makeProfileModelsData(from: []))
        let expectation = expectation(description: "Wait for async Code")
        sut.fetchUsers(search: "23", pageNumber: 1, pageSize: 12)
            .subscribe { profiles in
               XCTAssertEqual(profiles, [], "Expected to Complete with Empty empty profiles response")
                expectation.fulfill()
            } onFailure: { error in
                XCTFail("Expected to succeed with empty Profiles Response")
            }
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_OnFetch_returnsProfileModelArrayOnValidPResponses() {
        
        let item1 = makeProfileModel(name: "Profile1", type: "User", imageURL: URL(string: "http://www.anyurl.com")!)
        let item2 = makeProfileModel(name: "Profile2", type: "Admin", imageURL: URL(string: "http://www.another-url.com")!)
        let sut = makeSUT(for: 200, data: makeProfileModelsData(from: [item1.json, item2.json]))
        
        
        let expectation = expectation(description: "Wait for async Code")
        sut.fetchUsers(search: "23", pageNumber: 1, pageSize: 12)
            .subscribe { profiles in
                XCTAssertEqual(profiles, [item1.model, item2.model], "Expected to Complete with \([item1.model, item2.model])")
                expectation.fulfill()
            } onFailure: { error in
                XCTFail("Expected to succeed with Profiles in Response")
            }
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func makeSUT(for code: Int, data: Data) -> GitHubDataStore {
        let endPointStatusClosure = endPointClosureWithCode(statusCode: code, data: data)
        let provider = MoyaProvider<GitHub>(endpointClosure: endPointStatusClosure, stubClosure: MoyaProvider.immediatelyStub)
        
        let store = GitHubDataStoreImpl(provider: provider)
        return store
    }
    
    private func endPointClosureWithCode(statusCode: Int, data: Data) -> (GitHub) -> Endpoint {
        return { (target: GitHub) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(statusCode, data) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
    }
    
    private func anyData() -> Data {
        return Data()
    }
    
    private func makeProfileModel(name: String, type: String, imageURL: URL) -> (model: ProfileModel, json: [String: Any]) {
        let model = ProfileModel(name: name, type: type, imageURL: imageURL)
        let json: [String: Any] = [
            "login": name,
            "avatar_url": imageURL.absoluteString,
            "type": type
        ]
        return (model, json)
    }
    
    private func makeProfileModelsData(from profiles: [[String: Any]]) -> Data {
        let items = ["items": profiles]
        return try! JSONSerialization.data(withJSONObject: items)
    }
}
