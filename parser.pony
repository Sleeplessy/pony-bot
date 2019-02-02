use "json"

primitive CoolQParser
  fun parse_sex(sex': String): (Sexual|None) =>
    match sex'
    | "male" => Male
    | "female" => Female
    else
      None
    end

  // Parse CoolQ revceived msg event
  fun parse_post(post' : String): (Message| (String, String) | None) ? =>
    QQLogger.print(post')
    let doc = JsonDoc
    doc.parse(post')?
    let json: JsonObject = doc.data as JsonObject
    try
      let post_type: String = json.data("post_type")? as String
      QQLogger.print("Receive "+ post_type)
      match post_type
        | "message" =>
        let sender_data: JsonObject = json.data("sender")? as JsonObject
        let nick: String = sender_data.data("nickname")? as String
        let sex: (Sexual|None) = parse_sex(sender_data.data("sex")? as String)
        var msg_type: String = json.data("message_type")? as String
        let id: U64 = U64.from[I64](json.data("user_id")? as I64)
        let qq = QQ(id, nick, sex)
        let body: String = json.data("message")? as String
        match msg_type
          | "private" => PrivateChatMessage(qq, qq, body)
          | "group" =>
          let group_qq = QQ(U64.from[I64](json.data("group_id")? as I64), "", None)
          GroupChatMessage(qq, group_qq, body)
        else
          PrivateChatMessage.create(qq, qq, body)
        end
        |"request" =>
        let sub_type: String = json.data("sub_type")? as String
        match sub_type
          | "add" =>
          None
          | "invite" =>
          let flag: String = json.data("flag")? as String
          (flag, sub_type)
        end
        |"notice" => None
      else
        QQLogger.print("Error Parse post")
        error  
      end
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
