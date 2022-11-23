//
//  GiphySearchContainerViewControllerTests.swift
//  GiphyLookupApplicationTests
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import Combine
import GiphyLookup
import XCTest

@testable import GiphyLookupApplication

// MARK: XCTestCase

final class GiphySearchContainerViewControllerTests: XCTestCase {
    func test_view_shouldHaveTitle() {
        let (sut, _) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, "Trending 🔥")
    }

    func test_searchBar_shouldHavePlaceholder() {
        let (sut, _) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.navigationItem.searchController?.searchBar.placeholder, "Search GIPHY")
    }

    func test_childViewController_shouldEmbedGivenViewController() {
        let childViewController = UITableViewController()
        let (sut, _) = makeSystemComponentsUnderTest(childViewController: childViewController)

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.children, [childViewController])
    }

    func test_search_whenInputContainsEmptyValue_shouldNotExecuteSearch() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()

        let searchController = AlwaysActiveSearchController()
        searchController.searchBar.text = nil
        sut.updateSearchResults(for: searchController)

        XCTAssertEqual(spy.requests.count, 0)
    }

    func test_search_whenInputContainsNonEmptyValue_shouldExecuteSearchWithGivenValue() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()

        let expectation = expectation(description: "Wait for `\(sut)` to complete search.")
        spy.fetchListCompletion = { expectation.fulfill() }

        sut.simulateActiveSearchBarTextInput("Hello")
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(spy.requests, [.search(.init("Hello")!)])
    }

    func test_search_whenInputChangedMultipleTimes_shouldExecuteSearchDebauncingLastValue() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()

        let expectation = expectation(description: "Wait for `\(sut)` to complete search.")
        spy.fetchListCompletion = { expectation.fulfill() }

        sut.simulateActiveSearchBarTextInput("h")
        sut.simulateActiveSearchBarTextInput("Hel")
        sut.simulateActiveSearchBarTextInput("Hello")
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(spy.requests, [.search(.init("Hello")!)])
    }

    func test_search_whenClosed_shouldExecuteTrendingListEndpoint() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()

        let expectation = expectation(description: "Wait for `\(sut)` to dismiss search.")
        spy.fetchTrendingListCompletion = { expectation.fulfill() }

        sut.simulateInactiveSearchBarTextInput("Hello")
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(spy.requests, [.trending(offset: 0)])
    }

    private func makeSystemComponentsUnderTest(
        childViewController: UIViewController = UITableViewController()
    ) -> (GiphySearchContainerViewController, GiphyFetchableSpy) {
        let spy = GiphyFetchableSpy()
        let viewController = GiphySearchContainerViewController(
            viewModel: GiphyListController(
                giphyFetcher: spy,
                imagePrefetcher: spy,
                actions: GiphyListViewModelActions(
                    showDetails: { _ in },
                    showError: { _ in }
                ),
                scheduler: DispatchQueue.main
            ),
            childViewController: childViewController
        )
        trackForMemoryLeaks(viewController)
        return (viewController, spy)
    }
}

// MARK: -

// MARK: Simulation

extension GiphySearchContainerViewController {
    func simulateActiveSearchBarTextInput(_ input: String) {
        let searchController = AlwaysActiveSearchController()
        searchController.searchBar.text = input
        updateSearchResults(for: searchController)
    }

    func simulateInactiveSearchBarTextInput(_ input: String) {
        let searchController = AlwaysInactiveSearchController()
        searchController.searchBar.text = input
        updateSearchResults(for: searchController)
    }
}

// MARK: -

// MARK: Helpers

final class AlwaysActiveSearchController: UISearchController {
    override var isActive: Bool {
        get { true }
        set { super.isActive = newValue }
    }
}

final class AlwaysInactiveSearchController: UISearchController {
    override var isActive: Bool {
        get { false }
        set { super.isActive = newValue }
    }
}
