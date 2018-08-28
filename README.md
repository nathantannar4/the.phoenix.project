<img width="100%" src="./Public/phoenix-logo.png" alt="logo">

# The Phoenix Project

> A deployment ready template with support for authentication, real-time chat, push notifications, files, email verification

### phoe·nix

*noun*

> (in classical mythology) A unique bird that lived for five or six centuries in the Arabian desert, after this time burning itself on a funeral pyre and rising from the ashes with renewed youth to live through another cycle.

**Goal**: To establish an advanced template that lays the groundwork for common mobile app API functionality such as authentication, real-time chat and push notifications.

## Why Vapor?

"Server-side app development with Swift and Vapor is a unique experience. In contrast to many traditional server-side languages — for example PHP, JavaScript, Ruby — Swift is strongly- and statically-typed. This characteristic has greatly reduced the number of runtime crashes in iOS apps and your server-side apps will also enjoy this benefit.

Another potential benefit of server-side Swift is improved performance. Because Swift is a compiled language, apps written using Swift are likely to perform better than those written in an interpreted language.

> Excerpt From: By Tim Condon. "Server Side Swift with Vapor."

If you are unfamiliar with Vapor 3 please first see their [Getting Started Guide](https://docs.vapor.codes/3.0/)

## Requirements

- Swift 4.1
- Vapor 3
- Vapor Toolbox
- cURL (for Push Notifications)
- MySQL (other DBs are supported you will just have to modify the template)

## Build

```
vapor fetch
vapor build
```

## Run

```
vapor run
```

## Environment Variables

Default environment variables can be set in `Sources/App/Extensions/Environment+Extensions.swift`. Note, some do not have defaults so you will need to set them in your environment or docker container.

```
<enviornment_property>: <default_value>
DATABASE_HOSTNAME: "127.0.0.1"
DATABASE_PORT: 3306
DATABASE_USER: "root"
DATABASE_PASSWORD: "root"
DATABASE_DB: "vapor"
SENDGRID_API_KEY:
APP_NAME: "Phoenix App"
PUBLIC_URL: "127.0.0.1:<PORT>"
PORT: 8000
X_API_KEY: "myApiKey"
NO_REPLY_EMAIL: "no-reply@phoenix.io"
MOUNT:
STORAGE_PATH: "./Storage" 
PUSH_CERTIFICATE_PATH: "./Push/Certificates/aps.pem"
PUSH_CERTIFICATE_PWD: "password"
PUSH_DEV_CERTIFICATE_PATH: "./Push/Certificates/aps_development.pem"
PUSH_DEV_CERTIFICATE_PWD: "password"
BUNDLE_IDENTIFIER:
LOG_PATH: "./Logs"
```

## Deployment

### Vapor Cloud

See the Vapor Cloud [Quick Start](https://docs.vapor.cloud/quick-start/)

After configuring `cloud.yml`

```
vapor cloud deploy
```

### GCP, DigitalOcean, AWS or any other Linux Box

Deployment can be made easy with [capistrano](https://github.com/capistrano/capistrano). I recommend following [this great guide](https://medium.com/@timominous/deploying-a-vapor-app-to-a-remote-server-using-capistrano-3546b7bb2d5a).

After configuring `config/deploy.rb` and `config/deploy/production.rb`

```
cap deploy production
```

# Getting Started

## Auth

Controller: `AuthController.swift`

#### Register

> Register a new user, send an email verification if email supplied and SendGrid setup

Route: `POST /auth/register`

Required Headers: `X-API-KEY`

Payload: `{"username": String, "password": String, "email": String?}`

Returns: `User.Pulic`

> Example:

```
curl -X POST \
  http://localhost:8000/auth/register \
  -H 'Content-Type: application/json' \
  -H 'X-API-KEY: myApiKey' \
  -d '{
	"username":"nathantannar",
	"password":"password"
}'
```

```
{
    "username": "nathantannar",
    "id": "jXs74DRAV0",
    "updatedAt": "2018-08-28T17:43:04Z",
    "isEmailVerified": false,
    "createdAt": "2018-08-28T17:43:04Z"
}
```

#### Login

> Get a bearer token for authorization and starts an auth session for the user

Route: `POST /auth/login`

Required Headers: `X-API-KEY`, `Basic Authorization`

Returns: `BearerToken.Public`

> Example:

```
curl -X POST \
  http://localhost:8000/auth/login \
  -H 'Authorization: Basic bmF0aGFudGFubmFyOnBhc3N3b3Jk' \
  -H 'X-API-KEY: myApiKey'
```

```
{
    "value": "UqlsePL8CyIpE/Rp7aohzg==",
    "expiresAt": "2019-02-24T05:01:52Z",
    "updatedAt": "2018-08-28T05:01:52Z",
    "userId": "DI1IjCF7wI",
    "createdAt": "2018-08-28T05:01:52Z",
    "image": null
}
```

#### Verify Login

> Verify if the supplied bearer token is valid

Route: `GET /auth/verify/login`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `User.Public`

> Example:

```
curl -X POST \
  http://localhost:8000/auth/verify/login \
  -H 'Authorization: Bearer UqlsePL8CyIpE/Rp7aohzg==' \
  -H 'X-API-KEY: myApiKey'
```

```
{
    "username": "nathantannar",
    "id": "jXs74DRAV0",
    "updatedAt": "2018-08-28T17:43:04Z",
    "isEmailVerified": false,
    "createdAt": "2018-08-28T17:43:04Z",
    "image": null
}
```

#### Logout

> End the auth session for the user and invalidate the supplied bearer token

Route: `POST /auth/logout`

Required Headers: `X-API-KEY`, `Bearer Authorization`

> Example:

```
curl -X POST \
  http://localhost:8000/auth/logout \
  -H 'Authorization: Bearer UqlsePL8CyIpE/Rp7aohzg==' \
  -H 'X-API-KEY: myApiKey'
```

```
Status Code 200
```

#### Request Email Verification

> Email an email verification link to the authenticated users email

Route: `POST /auth/request/passwordreset`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `String` (result message)

#### Verify Email

> Verify a users email with the supplied token (sent in the verification email), invalidate the token after use

Route: `GET /auth/verify/email/:verifytoken`

Returns: `String` (result message)

#### Request Password Reset

> Email a password reset link to the users email

Route: `POST /auth/request/passwordreset`

Required Headers: `X-API-KEY`

Payload: `{"username": String, "password": String, "email": String?}`

Returns: `String` (result message)

#### Reset Password

> Resets the users password to a new temporary one, invalidate the token after use

Route: `GET /auth/reset/password/:verifytoken`

Returns: `String` (temporary password)

#### Change Password

> Verify auth session user is the same as payload user, resets the authenticated users password to the new password supplied in the payload

Route: `PUT /auth/reset/password/`

Payload: `{"username": String, "password": String}`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `HTTPStatus`

## Push Notifications

Controller: `InstallationController.swift` and `PushController.swift`

#### Register Installation

> Register a device token for an authenticated user

Route: `POST /installation`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Payload: `{"userId": String, "deviceToken": String, ...}`

Returns: `Installation.Public`

*For other CRUD operations on `Installation` see `InstallationController.swift`*

#### Push

> Send an `APNSPayload` to Apples APNS servers for each device token

Route: `POST /push`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Payload: `{"payload": APNSPayload, "users": [User.ID]}`

Returns: `[PushRecord.Public]`

#### Push to User

> Send an `APNSPayload` to Apples APNS servers for each user's device token

Route: `POST /push/:userId`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Payload: `APNSPayload `

Returns: `[PushRecord.Public]`

> Example:

```
curl -X POST \
  http://localhost:8000/push/jXs74DRAV0 \
  -H 'Authorization: Bearer UqlsePL8CyIpE/Rp7aohzg==' \
  -H 'Content-Type: application/json' \
  -H 'X-API-KEY: myApiKey' \
  -d '{
	"title":"Test",
	"subtile": "Hello, World!",
	"sound":"default",
	"contentAvailable": false,
	"hasMutableContent": false,
	"extra": {}
}'
```

## Real-Time Chat

Controller: `ConversationSocketController.swift` and `ConversationController.swift`

#### Create Conversation

> Creates a new `Conversation` and adds the user as a member

Route: `POST /conversations`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Payload: `{"name": String?}`

Returns: `[Conversation.Detail]`

> Example:

```
curl -X POST \
  http://localhost:8000/conversations\
  -H 'Authorization: Bearer UqlsePL8CyIpE/Rp7aohzg==' \
  -H 'Content-Type: application/json' \
  -H 'X-API-KEY: myApiKey'
```

```
{
    "connectedUsers": []
    "id": "DIuyhSwUIf",
    "users": [
        {
            "username": "nathantannar4@gmail.com",
            "id": "DI1IjCF7wI",
            "email": "nathantannar4@gmail.com",
            "updatedAt": "2018-08-28T05:00:13Z",
            "isEmailVerified": false,
            "createdAt": "2018-08-28T05:00:13Z"
        }
    ],
    "updatedAt": "2018-08-28T05:02:52Z",
    "lastMessage": null
    "createdAt": "2018-08-28T05:02:52Z"
}
```

#### Join Conversation

> Join an existing `Conversation`

Route: `POST /conversations/:conversationId/join`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `ConversationUser`

#### Leave Conversation

> Leave an existing `Conversation`

Route: `POST /conversations/:conversationId/leave`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `ConversationUser`

#### Get Conversations

> Fetch all `Conversation`s that the authenticated user is a member of

Route: `GET /conversations`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `[Conversation.Detail]`

#### Get Conversation's Messages

> Fetch all `Message`s for a `Conversation`

Route: `GET /conversations/:conversationId/messages`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `[Message.Detail]`

> Example:

```
curl -X GET \
  http://localhost:8000/conversations/DIuyhSwUIf/messages \
  -H 'Authorization: Bearer UqlsePL8CyIpE/Rp7aohzg==' \
  -H 'Content-Type: application/json' \
  -H 'X-API-KEY: myApiKey'
```

```
[
    {
        "text": "Hello, World!",
        "id": "r2mBrtWwNw",
        "user": {
            "username": "nathantannar4@gmail.com",
            "id": "DI1IjCF7wI",
            "email": "nathantannar4@gmail.com",
            "updatedAt": "2018-08-28T05:00:13Z",
            "isEmailVerified": false,
            "createdAt": "2018-08-28T05:00:13Z"
        },
        "updatedAt": "2018-08-28T17:06:37Z",
        "createdAt": "2018-08-28T17:06:37Z"
    },
    {
        "text": "Hello",
        "id": "ZZubNDEWeG",
        "user": {
            "username": "nathantannar4@gmail.com",
            "id": "DI1IjCF7wI",
            "email": "nathantannar4@gmail.com",
            "updatedAt": "2018-08-28T05:00:13Z",
            "isEmailVerified": false,
            "createdAt": "2018-08-28T05:00:13Z"
        },
        "updatedAt": "2018-08-28T17:29:06Z",
        "createdAt": "2018-08-28T17:29:06Z"
    }
]
```

#### Create a Message

> Create `Message` in a `Conversation` (non real-time)

Route: `POST /conversations/:conversationId/messages`

Required Headers: `X-API-KEY`, `Bearer Authorization`

Returns: `Message.Detail`

> Example: 

```
curl -X POST \
  http://localhost:8000/conversations/DIuyhSwUIf/messages \
  -H 'Authorization: Bearer UqlsePL8CyIpE/Rp7aohzg==' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 73a5920e-dc75-4877-aba1-11901de23880' \
  -H 'X-API-KEY: myApiKey' \
  -d '{
	"userId": "DI1IjCF7wI",
	"conversationId": "DIuyhSwUIf",
	"text": "Hello, World!"
}'
```

```
{
    "text": "Hello, World!",
    "id": "HRGPSmvarY",
    "user": {
        "username": "nathantannar4@gmail.com",
        "id": "DI1IjCF7wI",
        "email": "nathantannar4@gmail.com",
        "updatedAt": "2018-08-28T05:00:13Z",
        "isEmailVerified": false,
        "createdAt": "2018-08-28T05:00:13Z"
    },
    "updatedAt": "2018-08-28T17:54:04Z",
    "createdAt": "2018-08-28T17:54:04Z"
}
```

#### Real-Time Web Socket

> Join a socket for a `Conversation` that the authenticated user is already a member of

Route: `WS /conversations/:conversationId`

Required Headers: None (*Sockets do not support middleware to my knowledge*)

> Example:

```
wsta ws://localhost:8000/conversations/DIuyhSwUIf/DI1IjCF7wI

Recieved: 
{
    "connectedUsers": [
        {
            "updatedAt": "2018-08-28T17:50:29Z",
            "userId": "DI1IjCF7wI"
        }
    ],
    "id": "DIuyhSwUIf",
    "users": [
        {
            "username": "nathantannar4@gmail.com",
            "id": "DI1IjCF7wI",
            "email": "nathantannar4@gmail.com",
            "updatedAt": "2018-08-28T05:00:13Z",
            "isEmailVerified": false,
            "createdAt": "2018-08-28T05:00:13Z"
        }
    ],
    "updatedAt": "2018-08-28T05:02:52Z",
    "lastMessage": {
        "text": "Hello, World!",
        "id": "HRGPSmvarY",
        "user": {
            "username": "nathantannar4@gmail.com",
            "id": "DI1IjCF7wI",
            "email": "nathantannar4@gmail.com",
            "updatedAt": "2018-08-28T05:00:13Z",
            "isEmailVerified": false,
            "createdAt": "2018-08-28T05:00:13Z"
        },
        "updatedAt": "2018-08-28T17:54:04Z",
        "createdAt": "2018-08-28T17:54:04Z"
    },
    "createdAt": "2018-08-28T05:02:52Z"
}

Send:
{
	"userId": "DI1IjCF7wI",
	"isTyping": true
}

Send:
{
	"userId": "DI1IjCF7wI",
	"isTyping": false
}

Send:
{
	"userId": "DI1IjCF7wI",
	"conversationId": "DIuyhSwUIf",
	"text": "Hello, World!"
}

Recieve:
{
    "text": "Hello, World!",
    "id": "HRGPSmvarY",
    "user": {
        "username": "nathantannar4@gmail.com",
        "id": "DI1IjCF7wI",
        "email": "nathantannar4@gmail.com",
        "updatedAt": "2018-08-28T05:00:13Z",
        "isEmailVerified": false,
        "createdAt": "2018-08-28T05:00:13Z"
    },
    "updatedAt": "2018-08-28T17:54:04Z",
    "createdAt": "2018-08-28T17:54:04Z"
}

```

When connected, the socket will accept `Message` and `TypingStatus` binary data in addition to `String`s which it will convert to a `Message`.

Data sent to the socket will be propogated to all the other connections in the "room", this includes saved `Message`s and `TypingStatus`.

Whenever a user connects or disconnects the socket sends an updated `Conversation` to all connections

*For other CRUD operations on `Message` and `Conversation` see `InstallationController.swift`*

## References

- [Vapor 3 Docs](https://docs.vapor.codes/3.0/)
- [Server Side Swift with Vapor](https://store.raywenderlich.com/products/server-side-swift-with-vapor), by Time Condon
- [Vapor School](https://github.com/vaporberlin/vaporschool)
