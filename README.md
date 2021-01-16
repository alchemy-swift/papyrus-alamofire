# PapyrusAlamofire

Requesting [Papyrus](https://github.com/alchemy-swift/alchemy/blob/main/Docs/4_Papyrus.md) API definitions with Alamofire.

## Usage

Define an API...
```swift
class TodosAPI: EndpointGroup {
    @GET("/todos")
    var getAll: Endpoint<GetTodosRequest, [TodoDTO]>

    struct GetTodosRequest: EndpointRequest {
        @URLQuery
        var limit: Int

        @URLQuery
        var incompleteOnly: Bool
    }

    struct TodoDTO: Codable {
        var name: String
        var isComplete: Bool
    }
}
```

...and request it.

```swift
import PapyrusAlamofire

let todosAPI = TodosAPI(baseURL: "http://localhost:8888")
todosAPI.getAll
    .request(.init(limit: 50, incompleteOnly: true)) { response, todoResult in
        switch todoResult {
        case .success(let todos):
            for todo in todos {
                print("Got todo: \(todo.name)")
            }
        case .failure(let error):
            print("Got error: \(error).")
        }
    }
```
