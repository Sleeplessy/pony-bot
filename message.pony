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

primitive QQLogger
  fun print(log: String) =>
    let out_log = recover String(log.size() + 1) end
    out_log.append(log)
    out_log.append("\n")
    @printf[I32](out_log.cstring())

class PrivateChatMessage is Message
  let _sender: QQ
  var _receiver: QQ
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

  fun ref set_receiver(receiver': QQ) => _receiver = receiver'
    
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
