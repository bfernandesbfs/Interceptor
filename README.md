# Interceptor

Interceptor is a Package that tries to resolver problem when need to have some configurations to network API and your response. We need to intercept some information or add to global configurations, of basis form centralized with based on principle single responsibility, the idea behind this package is simple, but the implementation is a bit manual, look the image below.

![alt text](./Docs/Img/Img01.png)
 
 In this case, Interceptor is applied after URLRequest was created and applied after URLSession callback
 
## How to work this?

At first, after setup was applied in your code, we need to create interceptor objects based on two protocol `ResquestInterceptor` and `ResponseInterceptor`   

### ResquestInterceptor

``` swift

struct TokenInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws {
        request.addValue("Bearer HASH-test-1234", forHTTPHeaderField: "Authorization")
    }
}

```

### ResponseInterceptor

```swift

class BlockInterceptorSpy: ResponseInterceptor {

    func intercept(_ data: Data?, response: URLResponse?, error: Error?) {
        
        if let value = response as? HTTPURLResponse, value.statusCode == 401 {
            ...
        }
        
    }

}

```

### Adding on linked chain 

After this, we can add these objects to linked chain [(Look implementation here)](https://github.com/bfernandesbfs/Responder) based on **Responder package**, we going to add each object througt function `Interceptor.add`

```swift

var interceptor = Interceptor()
interceptor.add(TokenInterceptor()).add(BlockInterceptorSpy())

```

### Applying in your code

It's very simple, look code below:

Here, we apply request interceptor after creating `URLRequest`,  function `applyRequest` will walk each object added that correlated with `ResquestInterceptor` and will change this with applying new data or override some data of your implementation

```swift

let url = URL(string: "http://test.com")
var request = URLRequest(url: url)
try interceptor.applyRequest(&request)

```

next point is, add the interceptor after callback URLSession in your code. This point simplest easy, just put function `applyResponse` on property `completionhandler`, your types are equals.

```swift

let task = session.dataTask(with: url, completionHandler: interceptor.applyResponse { data, response, error in
    ...
})
task.resume()

```

that's it! 

## How to install this?

### Swift Package Manager

To use `Interceptor` as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` swift

.package(url: "https://github.com/bfernandesbfs/Interceptor.git", .upToNextMajor(from: "0.0.1"))

```

> Interceptor has dependency of [Responder Package](https://github.com/bfernandesbfs/Responder)

## License

[Here](./LICENSE)
