# SearchIOSApp

A coding assignment implemneted Using MVVM, RxSwift and Moya.

## UseCase

- After the app is launched, the **Search** component is displayed
- The user enters a random String value into to the 'Login' field and clicks the 'Submit' button
- The app sends a http request to `https://api.github.com/search/users?q={login} in:login`, where {login} is the String value entered by the user
- The app then parses the response from the server. If data is returned, the **Results** component should display the fetched values. If there is an issue with the request, then an error message should be displayed.

## APIContract

```
https://api.github.com/search/users?q={login}

{
  "total_count": 9173,
  "incomplete_results": false,
  "items": [
    {
      "login": "usman",
      "id": 2697,
      "node_id": "MDQ6VXNlcjI2OTc=",
      "avatar_url": "https://avatars.githubusercontent.com/u/2697?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/usman",
      "html_url": "https://github.com/usman",
      "followers_url": "https://api.github.com/users/usman/followers",
      "following_url": "https://api.github.com/users/usman/following{/other_user}",
      "gists_url": "https://api.github.com/users/usman/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/usman/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/usman/subscriptions",
      "organizations_url": "https://api.github.com/users/usman/orgs",
      "repos_url": "https://api.github.com/users/usman/repos",
      "events_url": "https://api.github.com/users/usman/events{/privacy}",
      "received_events_url": "https://api.github.com/users/usman/received_events",
      "type": "User",
      "site_admin": false,
      "score": 1.0
    },
    {
      "login": "usmanhalalit",
      "id": 981039,
      "node_id": "MDQ6VXNlcjk4MTAzOQ==",
      "avatar_url": "https://avatars.githubusercontent.com/u/981039?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/usmanhalalit",
      "html_url": "https://github.com/usmanhalalit",
      "followers_url": "https://api.github.com/users/usmanhalalit/followers",
      "following_url": "https://api.github.com/users/usmanhalalit/following{/other_user}",
      "gists_url": "https://api.github.com/users/usmanhalalit/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/usmanhalalit/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/usmanhalalit/subscriptions",
      "organizations_url": "https://api.github.com/users/usmanhalalit/orgs",
      "repos_url": "https://api.github.com/users/usmanhalalit/repos",
      "events_url": "https://api.github.com/users/usmanhalalit/events{/privacy}",
      "received_events_url": "https://api.github.com/users/usmanhalalit/received_events",
      "type": "User",
      "site_admin": false,
      "score": 1.0
    },
    ]
}
```
