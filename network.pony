// Network handler
use "http"
use "encode/base64"
use "websocket"

class ListenNotify is WebSocketListenNotify
  // A tcp connection connected, return a WebsocketConnectionNotify instance
  fun ref connected(): ConnectionNotify iso^ =>
    ConnectionNotify

  fun ref not_listening() =>
    @printf[I32]("Failed listening\n".cstring())

class ConnectionNotify is WebSocketConnectionNotify
  // A websocket connection enters the OPEN state
  fun ref opened(conn: WebSocketConnection ref) =>
    @printf[I32]("New client connected\n".cstring())

  // UTF-8 text data received
  fun ref text_received(conn: WebSocketConnection ref, text: String) =>
    let output = recover String(text.size() + 1) end // add a new line
    output.append(text)
    output.append("\n")
    @printf[I32](output.cstring())

  // Binary data received
  fun ref binary_received(conn: WebSocketConnection ref, data: Array[U8] val) =>
    conn.send_binary(data)

  // A websocket connection enters the CLOSED state
  fun ref closed(conn: WebSocketConnection ref) =>
    @printf[I32]("Connection closed\n".cstring())



actor GetWork
  """
  Do the work of fetching a resource
  """
  let _env: Env

  new create(env: Env, url: URL, user: String, pass: String, output: String)
    =>
    """
    Create the worker actor.
    """
    _env = env

    try
      // The Client manages all links.
      let client = HTTPClient(env.root as AmbientAuth)
      // The Notify Factory will create HTTPHandlers as required.  It is
      // done this way because we do not know exactly when an HTTPSession
      // is created - they can be re-used.
      let dumpMaker = recover val NotifyFactory.create(this) end

      try
        // Start building a GET request.
        let req = Payload.request("POST", url)
        req("User-Agent") = "Pony QQ-bot"
        req("Content-Type") = "application/json"

        req.add_chunk(output)
        // Add authentication if supplied.  We use the "Basic" format,
        // which is username:password in base64.  In a real example,
	      // you would only use this on an https link.
        if user.size() > 0 then
          let keyword = "Basic "
          let content = recover String(user.size() + pass.size() + 1) end
          content.append(user)
          content.append(":")
          content.append(pass)
          let coded = Base64.encode(consume content)
          let auth = recover String(keyword.size() + coded.size()) end
          auth.append(keyword)
          auth.append(consume coded)
          req("Authorization") = consume auth
        end
      

        // Submit the request
        let sentreq = client(consume req, dumpMaker)?

        // Could send body data via `sentreq`, if it was a POST
      else
        try env.out.print("Malformed URL: " + env.args(1)?) end
      end
    else
      env.out.print("unable to use network")
    end

  be cancelled() =>
    """
    Process cancellation from the server end.
    """
    _env.out.print("-- response cancelled --")

  be have_response(response: Payload val) =>
    """
    Process return the the response message.
    """
    if response.status == 0 then
      _env.out.print("Failed")
      return
    end

    // Print the status and method
    _env.out.print(
      "Response " +
      response.status.string() + " " +
      response.method)
    _env.out.print("")

    // Print the body if there is any.  This will fail in Chunked or
    // Stream transfer modes.
    try
      let body = response.body()?
      for piece in body.values() do
        _env.out.write(piece)
      end
      _env.out.print("")
    end

  be have_body(data: ByteSeq val)
    =>
    """
    Some additional response data.
    """
    _env.out.write(data)
    _env.out.print("")

  be finished() =>
    """
    End of the response data.
    """
    _env.out.print("-- end of body --")

class NotifyFactory is HandlerFactory
  """
  Create instances of our simple Receive Handler.
  """
  let _main: GetWork

  new iso create(main': GetWork) =>
    _main = main'

  fun apply(session: HTTPSession): HTTPHandler ref^ =>
    HttpNotify.create(_main, session)

class HttpNotify is HTTPHandler
  """
  Handle the arrival of responses from the HTTP server.  These methods are
  called within the context of the HTTPSession actor.
  """
  let _main: GetWork
  let _session: HTTPSession

  new ref create(main': GetWork, session: HTTPSession) =>
    _main = main'
    _session = session

  fun ref apply(response: Payload val) =>
    """
    Start receiving a response.  We get the status and headers.  Body data
    *might* be available.
    """
    _main.have_response(response)

  fun ref chunk(data: ByteSeq val) =>
    """
    Receive additional arbitrary-length response body data.
    """
    _main.have_body(data)

  fun ref finished() =>
    """
    This marks the end of the received body data.  We are done with the
    session.
    """
    _main.finished()
    _session.dispose()

  fun ref cancelled() =>
    _main.cancelled()
    
