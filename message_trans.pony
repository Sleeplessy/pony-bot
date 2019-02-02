// contains functions to trans Messages
use "http"
use "json"

actor RequestSender
  let base_url: String
  let _env: Env
  new create(base_url': String, env': Env) =>
    base_url = base_url'
    _env = env'
  be send(content: String, endpoint: String) =>
    let url' = recover String(base_url.size() + endpoint.size()) end
    url'.append(base_url)
    url'.append(endpoint)
    try
      let url = URL.valid(consume url')?
      _env.out.print(url.string())
      GetWork(_env, url, "", "", content)
    end


class MessageTransfer
  let _sender: RequestSender
  let _env: Env

  new create(base_url: String, env': Env) =>
    _env = env'
    _sender = RequestSender.create(base_url, _env)
  
  fun send(msg: Message) =>
    match msg
      | let trans: PrivateChatMessage =>
      send_private(trans)
      | let trans: GroupChatMessage =>
      send_public(trans)
    end

  fun send_private(msg: PrivateChatMessage) =>
    let json = CoolQParser.gen_msg_json(msg)
    _sender.send(json.string(), "send_msg")

  fun send_public(msg: GroupChatMessage) =>
    let json = CoolQParser.gen_msg_json(msg)
    _sender.send(json.string(), "send_msg")

  fun accept_invite(flag': String, type': String) =>
    let json = JsonObject()
    json.data("flag") = flag'
    json.data("approve") = true
    _sender.send(json.string(), "set_group_add_request")
