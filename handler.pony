use "random"
use "time"
use "regex"


trait QQMessageHandler
  fun deal_msg(msg: Message): (Message|None)


// trans messages into specific handler
primitive Diliver
  fun deal_msg(msg: Message): (Message|None) =>
    let body = msg.body()
    if is_command(body) then
      msg.set_body(get_param(body))
      try match get_command(body)?
        | "r" =>
        DiceHandler.deal_msg(msg)
          end
        end
      end
    

  fun is_command(body: String): Bool =>
    try
      let command_regex = Regex("^.(\\w+)")? // match for ".xxx"
      let command_matched = command_regex(body)?
      true
    else
      false
    end

  fun get_command(body: String): String ? =>
    try
      let command_regex = Regex("^.(\\w+)")? // match for ".xxx"
      command_regex(body)?.groups()(0)?
    else
      error
    end

  fun get_param(body: String): String  =>
    try
      let param_regex = Regex("\\.\\D*[[:blank:]](.*)")?
      param_regex(body)?.groups()(0)?
    else
      ""
    end
    

// Dice Roller
primitive DiceHandler is QQMessageHandler
  fun roll(count: U64, sides: U64): U64 =>
    let random = Rand(U64.from[I64](Time.seconds()), Time.nanos())
    let dice = Dice(random)
    dice.apply(count, sides)
    
    
  fun deal_msg(msg': Message): (Message|None) =>
    try
      (var count, var sides) = dice_parser(msg'.body())?
      let dice = roll(count, sides)
      let hint = "掷骰子 "
      let res_str = recover String(hint.size() + msg'.body().size() + dice.string().size() + 4) end
      res_str.append(hint)
      res_str.append(msg'.body())
      res_str.append(" ：")
      res_str.append(dice.string())
      match msg'
        |let msg: GroupChatMessage =>
        GroupChatMessage(msg'.receiver(), msg'.receiver(), consume res_str)
        |let msg: PrivateChatMessage =>
        PrivateChatMessage(msg'.receiver(), msg'.receiver(), consume res_str)
      end
      
        
    else
      None
    end

  // I hate regex
  fun dice_parser(dice: String): (U64, U64) ? =>
    let err = "Start parsing:" + dice + "\n"
    @printf[I32](err.cstring())
    try
      let count_reg = Regex("(\\d*)D")? // matches things before "D"
      let count_matched  = count_reg(dice)?.groups()(0)?
      let count: U64 = count_matched.u64()?


      let sides_reg = Regex("D(\\d*)")? // matches things before "D"
      let sides_matched  = sides_reg(dice)?.groups()(0)?
      let sides: U64 = sides_matched.u64()?
      (count, sides)
    else
      var error_info = "Error at dice parsing:" + dice + "\n"
      @printf[I32](error_info.cstring())
      error
    end

