# Interceptor

Interceptor is a Package that tries to solve problems when need to have some configurations to network API and its response. We need to intercept some information or add global configurations in centralized form based on the principle of single responsibility. The idea behind this package is simple, but the implementation requires a bit of preparation, look the image below.

![alt text](./Docs/Img/Img01.png)
 
In this case, Interceptor is applied after `URLRequest` is created and applied after `URLSession` callback
 
## How does this work?

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

### Adding on linked list 

After this, we can add these objects to linked list [(Look implementation here)](https://github.com/bfernandesbfs/Responder) based on **Responder package**, we are going to add each object through the function `Interceptor.add(_ :)`

```swift

var interceptor = Interceptor()
interceptor.add(TokenInterceptor()).add(BlockInterceptorSpy())

```

### Applying in your code

It's very simple, look at the code bellow:

Here, we apply request interceptor after creating `URLRequest`, the function `applyRequest` will go through each object added and correlated with `ResquestInterceptor` and will change or apply some data to it.

```swift

let url = URL(string: "http://test.com")
var request = URLRequest(url: url)
try interceptor.applyRequest(&request)

```

next step, add the interceptor after URLSession's callback in your code. This point is really easy, just put function `applyResponse` on property `completionhandler`, its types are equals.

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
