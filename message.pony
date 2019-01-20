// Below defines a QQ message
use "json"
primitive GenericChatMessageType

primitive PrivateChatMessageType
  
primitive GroupChatMessageType


type MessageType is (GenericChatMessageType | PrivateChatMessageType | GroupChatMessageType)


trait Message
  fun body(): String
  fun ref sender(): QQ
  fun ref receiver(): QQ
  fun msg_type(): MessageType
  fun ref set_body(body': String)


class PrivateChatMessage is Message
  let _sender: QQ
  let _receiver: QQ
  var _body: String
  
  new create(sender': QQ, receiver': QQ, body': String) =>
    _sender = sender'
    _receiver = receiver'
    _body = body'

  fun body(): String => _body

  fun ref sender(): QQ  => _sender

  fun ref receiver(): QQ  => _receiver

  fun msg_type(): MessageType => PrivateChatMessageType

  fun ref set_body(body': String) => _body = body'

// 
class GroupChatMessage is Message
  let _sender: QQ
  let _receiver: QQ
  var _body: String
  
  new create(sender': QQ, receiver': QQ,body': String) =>
    _sender = sender'
    _receiver = receiver'
    _body = body'

  fun body(): String => _body

  fun ref sender(): QQ  => _sender

  fun ref receiver(): QQ => _receiver

  fun msg_type(): MessageType => PrivateChatMessageType

  fun ref set_body(body': String) => _body = body'


primitive CoolQParser
  fun parse_sex(sex': String): (Sexual|None) =>
    match sex'
    | "male" => Male
    | "female" => Female
    else
      None
    end

  // Parse CoolQ revceived msg event
  fun parse_post(post' : String): (Message|None) ? =>
    let doc = JsonDoc
    doc.parse(post')?
    let json: JsonObject = doc.data as JsonObject
    try
      let sender_data: JsonObject = json.data("sender")? as JsonObject
      let nick: String = sender_data.data("nickname")? as String
      let sex: (Sexual|None) = parse_sex(sender_data.data("sex")? as String)
      var msg_type: String = json.data("message_type")? as String
      let id: U64 = U64.from[I64](json.data("user_id")? as I64)
      let qq = QQ(id, nick, sex)
      let body: String = json.data("message")? as String
      @printf[I32]((post' + "\n").cstring())
      match msg_type
        | "private" => PrivateChatMessage(qq, qq, body)
        | "group" =>
        let group_qq = QQ(U64.from[I64](json.data("group_id")? as I64), "", None)
        GroupChatMessage(qq, group_qq, body)
      else
        PrivateChatMessage.create(qq, qq, body)
      end
    else
      @printf[I32]("Error Parse post".cstring())
      error
    end

  fun gen_msg_json(raw: Message): JsonObject =>
    let json: JsonObject = JsonObject()
    match raw
      | let msg: PrivateChatMessage =>
      json.data("message_type") = "private"
      json.data("user_id") = I64.from[U64](msg.receiver().qq())
      | let msg: GroupChatMessage =>
      json.data("message_type") = "group"
      json.data("group_id") = I64.from[U64](msg.receiver().qq())
    end
    json.data("message") = raw.body()
    json
