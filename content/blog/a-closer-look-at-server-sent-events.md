---
title: "A Closer Look at Server Sent Events"
date: 2023-02-01T13:59:11+05:30
draft: false
---

Server-Sent Events (SSE) which first appeared in the HTML5 specification in late 2009 is relatively new are a simple and efficient way for a server to PUSH data to a client in real-time over HTTP.
The goal of this article is to give you an overview on where the technology currently sits and what are some possible usecases to introduce it.

Here's a glimpse of what we will be going through

- [Looking at the HTML5 Specification](#looking-at-the-html5-specification)
- [What's in it for me?](#whats-in-it-for-me)
- [Limitations of Server-Sent Events](#limitations-of-server-sent-events)
- [A look at other real-time communication technologies](#a-look-at-other-real-time-communication-technologies)
- [Hands on 🙌🏽](#hands-on-)
  - [Implementing a SSE Webserver in Go](#implementing-a-sse-webserver-in-go)
  - [Implementing a SSE client using `EventSource`](#implementing-a-sse-client-using-eventsource)
- [Conclusion](#conclusion)
- [Resources](#resources)

## Looking at the [HTML5 Specification](https://html.spec.whatwg.org/multipage/server-sent-events.html#server-sent-events)

SSE enables a server to send data to a client by "server push". The client establishes an HTTP connection to a server and keeps the connection open. The server can then continouslly send messages. A message is terminated by a blank line (two line terminators in a row). The data transfer mode is uni-directional beacause only the "server" is allowed to send data after establisihing a connection.

Here's how a sample SSE stream looks like

![sse](https://user-images.githubusercontent.com/34342551/216042287-b3ecb636-cd4e-46ff-b16d-8efe14770cab.svg)


## What's in it for me?

Although realtively knew, SSEs can be a viable solution. The offer various advantages:

- Low latency and real-time updates
- Simple and efficient server-to-client communication
- Improved scalability and reduced server load

A perfect use-case for SSE is the "notification tab 🔔" which is present on every kind of product nowadays. A server can be configured to push notifications to any client every time something happens in the product. For e.g you can award users with points every time they complete a step of onboarding.

## Limitations of Server-Sent Events

- Limited browser support
- Lack of support for older browsers
- Security concerns

## A look at other real-time communication technologies

- WebSockets
- AJAX
- Long Polling
- WebRTC

## Hands on 🙌🏽

### Implementing a SSE Webserver in Go

Let's get down to some business, in this section we will be using [r3labs/sse](https://github.com/r3labs/sse) to implement a simple SSE webserver.
Let's start by importing the said package and initialising our SSE server.

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
	mux := http.NewServeMux()

	addr := ":8080"
	log.Println("Starting server on", addr)

	err := http.ListenAndServe(addr, mux)
	if err != nil {
		log.Fatal(err)
	}

}
```

We now have a basic HTTP server running, lets create a stream where a client can listen for events and server can push events. We do this by calling the `CreateStream` function.

```go
server := sse.New()
server.CreateStream("messages")
```

Let's create 2 different handlers:

1. Where we tell our server to send us an event. Thing of this endpoint which is just reponsible for triggering.
2. Where the server will push events.

```go
mux := http.NewServeMux()
mux.HandleFunc("/events", server.ServeHTTP)
mux.HandleFunc("/trigger", logHTTPRequest(server))
```

Here the `/events` endpoint will be used to exchange "events" and the `/trigger` endpoint will tell our server to push the events in `messages` stream that we created earlier.

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

To publish an event we use the `server.Publish` function which takes a stream id (in our case "message") and a SSE event, `Event`.

That's it we now have a SSE server to publish events, lets quickly create a HTML client as well!

### Implementing a SSE client using `EventSource`

As discussed previously, the HTML5 standard declares the EventSource Web API.

The `EventSource()` constructor creates a new EventSource to handle receiving server-sent events from a specified URL.

The URL for our SSE server looks like this.

```bash
http://127.0.0.1:8080/events?stream=messages
```

Let's try to establish a SSE connection using this URL. Make sure to the server is running.

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

        // Read SSE logic
        const evtSource = new EventSource('http://127.0.0.1:8080/events?stream=messages');
        const eventList = document.querySelector('ul');

        evtSource.onmessage = (e) => {
            const newElement = document.createElement("li");

            newElement.textContent = `message: ${e.data}`;
            eventList.appendChild(newElement);
        }
    </script>
</body>

</html>
```

Here's a demo of how the client side works.

![SSE Web Client Demo](https://user-images.githubusercontent.com/34342551/216331453-dcc6edd5-58b4-4487-b5d8-ccccbf792118.gif)

## Conclusion

## Resources

- Make sure to show some 💚 to [r3labs/sse](https://github.com/r3labs/sse).
- [`EventSource MDN`](https://developer.mozilla.org/en-US/docs/Web/API/EventSource)
