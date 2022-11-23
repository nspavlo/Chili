//
//  GiphyCollectionViewControllerTests.swift
//  GiphyLookupApplicationTests
//
//  Created by Jans Pavlovs on 23/11/2022.
//

import Combine
import XCTest

@testable import GiphyLookup
@testable import GiphyLookupApplication

// MARK: XCTestCase

final class GiphyCollectionViewControllerTests: XCTestCase {
    func test_setup_whenViewIsLoaded_shouldSetupRefreshControlForScrollView() {
        let (sut, _) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.collectionView.refreshControl)
    }

    func test_setup_whenViewIsLoaded_shouldSetupEnablePrefetch() {
        let (sut, _) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.collectionView.isPrefetchingEnabled)
    }

    func test_setup_whenViewIsLoaded_shouldSetupPrefetchDataSource() {
        let (sut, _) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.collectionView.prefetchDataSource)
    }
}

// MARK: Requests

extension GiphyCollectionViewControllerTests {
    func test_requests_whenViewIsInitialized_shouldNotExecuteAnyRequests() {
        let (_, spy) = makeSystemComponentsUnderTest()

        XCTAssertEqual(spy.requests.count, 0)
    }

    func test_requests_whenViewIsLoaded_shouldExecuteTrendsRequest() {
        let (sut, spy) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        XCTAssertEqual(spy.requests, [.trending(offset: 0)])
    }

    func test_requests_whenUserInitiatesDataUpdate_shouldExecuteTrendsRequest() {
        let (sut, spy) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedDataUpdate()
        XCTAssertEqual(spy.requests, [.trending(offset: 0), .trending(offset: 0)])

        sut.simulateUserInitiatedDataUpdate()
        XCTAssertEqual(spy.requests, [.trending(offset: 0), .trending(offset: 0), .trending(offset: 0)])
    }

    func test_requests_whileLoadingTrends_shouldShowLoadingIndicator() {
        let (sut, spy) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isHeaderLoadingIndicatorVisible)

        spy.completeTrendingFetch(withEntries: makeFakeEntries())
        XCTAssertFalse(sut.isHeaderLoadingIndicatorVisible)

        sut.simulateUserInitiatedDataUpdate()
        XCTAssertTrue(sut.isHeaderLoadingIndicatorVisible)

        spy.completeTrendingFetch(withError: .anyError())
        XCTAssertFalse(sut.isHeaderLoadingIndicatorVisible)
    }

    func test_requests_shouldRenderGivenEntries() throws {
        let entries = makeFakeEntries()
        let (sut, spy) = makeSystemComponentsUnderTest()

        sut.loadViewIfNeeded()
        try expect(sut, toRender: [])

        spy.completeTrendingFetch(withEntries: entries)
        try expect(sut, toRender: entries)

        sut.simulateUserInitiatedDataUpdate()
        spy.completeTrendingFetch(withError: .anyError())
        try expect(sut, toRender: entries)
    }
}

// MARK: Pagination

extension GiphyCollectionViewControllerTests {
    func test_request_whenViewIsCloseToBottomAndAdditionalPagesAreNotAvailable_shouldNotRequestForMoreData() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()

        let withoutNextPage = Pagination(count: 0, offset: 0, totalCount: 0)
        spy.completeTrendingFetch(withEntries: makeFakeEntries(), pagination: withoutNextPage)
        sut.scrollViewDidScroll(CloseToBottomScrollView())

        XCTAssertEqual(spy.requests, [.trending(offset: 0)])
    }

    func test_request_whenViewIsCloseToBottomAndAdditionalPagesAreAvailable_shouldRequestForMoreData() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()
        let entries = makeFakeEntries()

        let withAvailablePagination = Pagination(count: 0, offset: 50, totalCount: 50)
        spy.completeTrendingFetch(withEntries: entries, pagination: withAvailablePagination)
        sut.scrollViewDidScroll(CloseToBottomScrollView())

        XCTAssertEqual(spy.requests, [.trending(offset: 0), .trending(offset: UInt(entries.count))])
    }

    func test_request_whenViewIsCloseToTopAndAdditionalPagesAreAvailable_shouldNotRequestForMoreData() {
        let (sut, spy) = makeSystemComponentsUnderTest()
        sut.loadViewIfNeeded()
        let entries = makeFakeEntries()

        let withAvailablePagination = Pagination(count: 0, offset: 50, totalCount: 50)
        spy.completeTrendingFetch(withEntries: entries, pagination: withAvailablePagination)
        sut.scrollViewDidScroll(UIScrollView())

        XCTAssertEqual(spy.requests, [.trending(offset: 0)])
    }
}

// MARK: Expectations

private extension GiphyCollectionViewControllerTests {
    func expect(
        _ sut: GiphyCollectionViewController,
        toRender items: [GIF],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTAssertEqual(sut.renderedItemsCount, items.count, file: file, line: line)

        try items
            .enumerated()
            .forEach { index, item in
                try expect(sut, toRenderConfiguredViewFor: item, at: index, file: file, line: line)
            }
    }

    func expect(
        _ sut: GiphyCollectionViewController,
        toRenderConfiguredViewFor data: GIF,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let cell = try XCTUnwrap(sut.renderedItemCell(at: index) as? GiphyCollectionViewCell, file: file, line: line)
        XCTAssertEqual(cell.accessibilityLabel, data.title, file: file, line: line)
    }
}

// MARK: -

// MARK: Factory Methods

private extension GiphyCollectionViewControllerTests {
    func makeSystemComponentsUnderTest(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: GiphyCollectionViewController, spy: GiphyFetchableSpy) {
        let spy = GiphyFetchableSpy()
        let sut = GiphyCollectionViewController(
            viewModel: GiphyListController(
                giphyFetcher: spy,
                imagePrefetcher: spy,
                actions: GiphyListViewModelActions(
                    showDetails: { _ in },
                    showError: { _ in }
                ),
                scheduler: ImmediateScheduler.shared
            ),
            collectionViewLayout: PinterestCollectionViewLayout()
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, spy)
    }

    func makeFakeEntries() -> [GIF] {
        [
            makeAnyEntry(withTitle: "1"),
            makeAnyEntry(withTitle: "2"),
            makeAnyEntry(withTitle: "3"),
        ]
    }

    func makeAnyEntry(withTitle title: String) -> GIF {
        GIF(title: title, images: Images(fixedWidth: makeAnyPreview(), original: makeAnyPreview()))
    }

    func makeAnyPreview() -> Preview {
        Preview(url: URL(string: "http://any-url.com")!, width: .init(rawValue: 100), height: .init(rawValue: 100))
    }
}

// MARK: -

// MARK: Helpers

final class CloseToBottomScrollView: UIScrollView {
    override var isDragging: Bool { true }

    override var contentOffset: CGPoint {
        get { .init(x: 0, y: 601) }
        set { super.contentOffset = newValue }
    }

    override var contentSize: CGSize {
        get { .init(width: 0, height: 900) }
        set { super.contentSize = newValue }
    }

    override var frame: CGRect {
        get { .init(origin: .zero, size: .init(width: 0, height: 300)) }
        set { super.frame = newValue }
    }
}

private extension UICollectionViewController {
    var refreshControl: UIRefreshControl? {
        collectionView.refreshControl
    }

    var isHeaderLoadingIndicatorVisible: Bool {
        refreshControl?.isRefreshing ?? false
    }

    func simulateUserInitiatedDataUpdate() {
        guard let refreshControl else {
            fatalError("Unable to simulate pull-to-refresh without `refreshControl` component")
        }

        refreshControl.simulatePullToRefresh()
    }
}

private extension UICollectionViewController {
    var renderedItemsSection: Int {
        0
    }

    var renderedItemsCount: Int {
        collectionView.numberOfItems(inSection: renderedItemsSection)
    }

    func renderedItemCell(at row: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: renderedItemsSection)
        return collectionView.dataSource!.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            let actions = actions(forTarget: target, forControlEvent: .valueChanged)
            actions?.forEach { (target as NSObject).perform(Selector($0)) }
        }
    }
}

private extension NSError {
    static func networkConnectionLostError() -> NSError {
        .init(domain: "a-domain", code: NSURLErrorNetworkConnectionLost)
    }

    static func anyError() -> NSError {
        networkConnectionLostError()
    }
}
