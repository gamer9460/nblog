---
title: "A Closer Look at Server-Sent Events"
date: 2023-02-01T13:59:11+05:30
draft: false
---

Server-Sent Events (SSE) which first appeared in the HTML5 specification in late 2009 is a simple and efficient way for a server to PUSH data to a client in real-time over HTTP.
The goal of this article is to give you an overview of where the technology currently sits and what are some possible use cases to introduce it.

Here's a glimpse of what we will be going through

- [Introduction](#introduction)
- [What's in it for me?](#whats-in-it-for-me)
- [A look at other real-time communication technologies](#a-look-at-other-real-time-communication-technologies)
- [Hands on 🙌🏽](#hands-on-)
  - [Implementing a SSE Web server in Go](#implementing-a-sse-web-server-in-go)
  - [Implementing a SSE client using `EventSource`](#implementing-a-sse-client-using-eventsource)
- [Conclusion](#conclusion)
- [Resources](#resources)

## Introduction

SSE enables a server to send data to a client by "server push". The client establishes an HTTP connection to a server and keeps the connection open. The server can then continuously send messages. A message is terminated by a blank line (two line terminators in a row). The data transfer mode is uni-directional because only the "server" is allowed to send data after establishing a connection.

Here's how a sample SSE stream looks like

![sse simple architecture](https://user-images.githubusercontent.com/34342551/216042287-b3ecb636-cd4e-46ff-b16d-8efe14770cab.svg)

## What's in it for me?

Although relatively new, SSE can be a viable solution. They offer various advantages:

- Low latency and real-time updates
- Simple and efficient server-to-client communication
- Improved scalability and reduced server load

A perfect use-case for SSE is the "notification tab 🔔" which is present on every kind of product nowadays.
A server can be configured to push notifications to any client every time something happens in the product. For, e.g. you can award users with points every time they complete a step of onboarding or add new data to their profile.

## A look at other real-time communication technologies

- WebSockets
- AJAX
- Long Polling
- WebRTC

## Hands on 🙌🏽

### Implementing a SSE Web server in Go

Let's get down to some business, in this section we will be using [r3labs/sse](https://github.com/r3labs/sse) to implement a simple SSE web server.
Let's start by importing the said package and initializing our SSE server.

```go
package main

import (
	"log"
	"net/http"
	"time"

	"github.com/r3labs/sse/v2"
)

func main() {
	server := sse.New()
    // prevents replaying old messages
    server.AutoReplay = false
	server.Headers = map[string]string{
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
	}

	mux := http.NewServeMux()

	addr := ":8080"
	log.Println("Starting server on", addr)

	err := http.ListenAndServe(addr, mux)
	if err != nil {
		log.Fatal(err)
	}

}
```

We now have a basic HTTP server running, let's create a stream where a client can listen for events and the server can push events. We do this by calling the `CreateStream` function.

```go
server := sse.New()
server.CreateStream("messages")
```

Let's create 2 different handlers:

1. Where we tell our server to send us an event. Think of this endpoint which is just responsible for triggering.
2. Where the server will push events.

```go
mux := http.NewServeMux()
mux.HandleFunc("/events", server.ServeHTTP)
mux.HandleFunc("/trigger", logHTTPRequest(server))
```

Here the `/events` endpoint will be used to exchange "events" and the `/trigger` endpoint will tell our server to push the events in the `messages` stream that we created earlier.

Let's write our `logHTTPRequest` handler that will push SSE events to all clients currently subscribed.

```go
func logHTTPRequest(server *sse.Server) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Got trigger request. Sending SSE")

		server.Publish("messages", &sse.Event{
			Data: []byte(time.Now().String()),
		})
		w.WriteHeader(200)
	}
}
```

To publish an event we use the `server.Publish` function which takes a stream ID (in our case "message") and a SSE event, `Event` in which we are sending latest timestamp in string form.

> Note that Event streams are always decoded as UTF-8.

That's it, we now have a SSE server to publish events. Run the server using `go run main.go` and you should see our log.

```txt
2023/02/02 22:40:39 Starting server on :8080

```

The URL for our SSE server where we will publish events looks like this.

```bash
http://127.0.0.1:8080/events?stream=messages
```

If you had to visit this URL on a browser, you can see that the request never finishes (since its streaming)

![Opening SSE URL on a browser](https://user-images.githubusercontent.com/122530514/216394847-fdbb9581-380e-417f-931b-9b0d9404d68e.gif)

Our next step is to build a SSE Client where we will create a connection using this URL.

### Implementing a SSE client using `EventSource`

The `EventSource()` constructor creates a new EventSource to handle receiving server-sent events from a specified URL.

Let's declare a boilerplate HTML code, that we will use to trigger the events from our server.

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SSE Client Demo</title>
</head>

<body>
    <h1>Demo Client for SSE</h1>
    <button type="button" id="triggerEvents">Trigger Event</button>
    <ul style="font-size: 25px;"></ul>
    <script>
        function triggerEvent() {
            fetch('http://127.0.0.1:8080/trigger', {
                method: 'GET',
            })
        }

        var btn = document.getElementById("triggerEvents");
        btn.addEventListener("click", triggerEvent);

        // TODO add code to listen to events and update DOM.

    </script>
</body>
</html>
```

As soon as we hit the trigger button, the server will send us an event. Let's add logic for listening to events

```js
// Read SSE logic
const evtSource = new EventSource('http://127.0.0.1:8080/events?stream=messages');
const eventList = document.querySelector('ul');

evtSource.onmessage = (e) => {
   const newElement = document.createElement("li");

   newElement.textContent = `message: ${e.data}`;
   eventList.appendChild(newElement);
}
```

Here's a demo of how the client side works.

![SSE Web Client Demo](https://user-images.githubusercontent.com/34342551/216331453-dcc6edd5-58b4-4487-b5d8-ccccbf792118.gif)

## Conclusion

## Resources

- [HTML SSE Standard](https://html.spec.whatwg.org/multipage/server-sent-events.html#server-sent-events)
- Make sure to show some 💚 to [r3labs/sse](https://github.com/r3labs/sse).
- [`EventSource MDN`](https://developer.mozilla.org/en-US/docs/Web/API/EventSource)
