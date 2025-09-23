# ``Sysctl``

A Swift interface for reading (and writing) `sysctl` values.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/swift-sysctl.git", from: "1.0.0"),
```

Or add it via Xcode (as of Xcode 11).

## Usage

Using Swift Sysctl is really easy. You just create a ``SystemControl`` instance and start accessing values. That's it:

```swift
let sysctl = SystemControl()
let machine = sysctl.hardware.machine // String with the value of `hw.machine`.
```

Swift Sysctl contains a few common values and will also grow over time.
If you find that you need a value that's not yet present, you can easily add them. Just read through the following sections.

### Namespaces

As you might now, `sysctl` addresses values using a name that has dots in it. Swift Sysctl calls the parts between these dots "namespace" and represents them in Swift `struct`s conforming to ``SysctlNamespace``. So for example, there's ``Hardware`` representing the `hw` namespace in `sysctl`.
Each namespace has a parent. If the namespace is located at the root, use the ``SysctlRootNamespace`` as parent.

When implementing your own namespaces, simply conform them to ``SysctlNamespace``, define the parent and implement `static var namePart: String { /*...*/ }`, returning the name part of your namespace (e.g. `hw` for ``Hardware``).

Here's an example for a new (imaginary) namespace that also has a child namespace:

```swift
struct Superpower: SysctlNamespace {
    typealias ParentNamespace = SysctlRootNamespace

    static var namePart: String { "spwr" }

    struct Control: SysctlNamespace {
        typealias ParentNamespace = Superpower

        static var namePart: String { "ctrl" }
    }

    var control: Control { .init() }
}

extension SysctlRootNamespace {
    var superpower: Superpower { .init() }
}
```

#### Fields

To access a value from `sysctl`, there are (computed) properties on the namespaces. So for example for `hw.machine` there's a property ``Hardware/machine`` on the ``Hardware`` namespace.
To access new values, simply declare a new (computed) property on the namespace the field is in (either in a namespace that you implemented on your own or by extending an existing one). The value type of these properties needs to be `Field<T>` where `T` is the type of value.
``SysctlNamespace/Field`` is a typealias for ``SysctlField`` inside a namespace. A field contains the last name part of the value's name. Thus you simply return the name as string.
If the value is writable, you also provide a `nonmutating set` implementation, which can be left empty.

Continuing our example, here's how fields on `Superpower` would look like:

```swift
extension Superpower {
    // The current magic level. Read-only.
    // The full name will be `spwr.curmaglvl`.
    var currentMagicLevel: Field<CInt> { "curmaglvl" }
}

extension Superpower.Control {
    // Whether superpowers are enabled. This is writable.
    // The full name will be `spwr.ctrl.enabled`.
    var isEnabled: Field<Bool> {
        get { "enabled" }
        nonmutating set {}
    }
}
```

### Values

For Swift Sysctl to know how to read (or write) a value into `sysctl`, it needs to conform to ``SysctlValue``. However, `sysctl` only supports very few value types, so it's very unlikely that you need to conform another type to it.

A bit more likely (but still not very likely) is that you want to have custom type that is represented by a value that already conforms to ``SysctlValue``. In this case, the ``SysctlValueRepresentable`` protocol is what your type needs to conform to. It behaves very similar to Swift's `RawRepresentable` protocol. You need to declare which underlying ``SysctlValue`` type your type will be using and implement the read-only property `var syctlValue: SysctlValue { get }` in which you return the underlying ``SysctlValue`` of your type. Then you ned to implement `init(sysctlValue:)` on your type. Swift Sysctl will pass the underlyling ``SysctlValue`` to this initializer and you are left with initializing your type from it.
With these requirements fulfilled, Swift Sysctl will provide the implementation for ``SysctlValue`` for you and you can read and write your type from/to `sysctl`.

Again continuing our example, here's how you would read a new type from `sysctl`:

```swift
enum MagicSpellPower: SysctlValueRepresentable {
    typealias SysctlValue = CInt

    case low(Int)
    case medium
    case high(unbeatable: Bool)

    var sysctlValue: SysctlValue {
        switch self {
        case .low(let val): return numericCast(val)
        case .medium: return 5
        case .high(let unbeatable): return unbeatable ? -1 : 10
        }
    }

    init(sysctlValue: SysctlValue) {
        switch sysctlValue {
        case 0..<5: self = .low(numericCast(sysctlValue))
        case 5: self = .medium
        case 10: self = .high(unbeatable: false)
        case -1: self = .high(unbeatable: true)
        default: fatalError("Invalid value: \(sysctlValue)")
        }
    }
}
```
