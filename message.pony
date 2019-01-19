// Below defines a QQ message
use "json"
primitive GenericChatMessageType

primitive PrivateChatMessageType
  
primitive GroupChatMessageType


type MessageType is (GenericChatMessageType | PrivateChatMessageType | GroupChatMessageType)


trait Message
  fun body() : String
  fun ref sender() : QQ
  fun ref receiver() : (QQ | None)
  fun msg_type() : MessageType


class PrivateChatMessage is Message
  let _sender : QQ
  let _receiver : QQ
  var _body : String
  
  new create(sender': QQ, receiver': QQ, body': String) =>
    _sender = sender'
    _receiver = receiver'
    _body = body'

  fun body() : String => _body

  fun ref sender() : QQ  => _sender

  fun ref receiver() : QQ  => _receiver

  fun msg_type() : MessageType => PrivateChatMessageType

// 
class GroupChatMessage is Message
  let _sender : QQ
  var _body : String
  
  new create(sender': QQ, receiver': QQ, body': String) =>
    _sender = sender'
    _receiver = receiver'
    _body = body'

  fun body() : String => _body

  fun ref sender() : QQ  => _sender

  fun ref receiver() => None

  fun msg_type() : MessageType => PrivateChatMessageType


primitive CoolQParser
  fun parse_sex(sex': String): (Sexual|None) =>
    match sex'
    | "male" => Male
    | "female" => Female
    else
      None
    end

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
      
      match msg_type
      | "private" => PrivateChatMessage.create(qq, qq, body)
      else
        PrivateChatMessage.create(qq, qq, body)
      end
    end
    
