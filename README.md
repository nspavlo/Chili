# GiphyLookup

![main workflow](https://github.com/nspavlo/Chili/actions/workflows/main.yml/badge.svg)

## Getting Started
**GiphyLookup** uses [Swift Package Manager](https://www.swift.org/package-manager/) to manage build dependencies and [MINT](https://github.com/yonaskolb/Mint) to install and run [Swift Lint](https://github.com/realm/SwiftLint) and [Swift Format](https://github.com/nicklockwood/SwiftFormat).

## Installation
Launch `GiphyLookup.xcodeproj` and run the `GiphyLookupApplication` scheme on a simulator or iOS device.

## Main Modules
Application is separated in two schemes:
-  GiphyLookup
-  GiphyLookupApplication 

This way, bigness logic stays platform agnostic, modular and fast to build and test. On every pull-reuqest, both modules will be built and tested.

## Data

Unfortunately, the data from bakend APIs isn’t always perfect. By default `JSONDecoder` will discard the whole collection when one of the elements are corrupted. To improve on this, application uses generic `LossyArray<T>` wrapper.

Some custom data types are introduced in order to remove assumtions about behaviour.
```swift
public struct SearchQuery {
    let value: String

    public init?(_ string: String?) {
        guard let string, !string.isEmpty else {
            return nil
        }

        value = string
    }
}
```
For example `SearchQuery` is used instead of plain `String`.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Links

- [Assignment](https://github.com/ChiliLabs/test-tasks/blob/master/ios_developer.md)
- [API Documentation](https://developers.giphy.com/docs/api/endpoint/)

## Build Tools
- Xcode 14.1 (14B47b)

## Author

[@JansPavlovs 👨‍💻](https://twitter.com/JansPavlovs)
