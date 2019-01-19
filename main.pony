use "files"

actor Main
  new create(env: Env) =>
    env.out.print("Test")
    let qq = QQ.create(719214425)
    env.out.print(qq.qq().string())
    env.out.print(qq.qq().string())
    let msg = PrivateChatMessage.create(qq,qq,"114514")
    env.out.print(msg.body())
    env.out.print(msg.sender().qq().string())
    CoolQParser.parse_sex("male")

    try
      let path = FilePath(env.root as AmbientAuth, "test.json")?
      match OpenFile(path)
      | let file: File =>
        while file.errno() is FileOK do
          var content: String = file.read_string(file.size())
          let parser = CoolQParser
          match parser.parse_post(content)?
            | let ms: PrivateChatMessage => env.out.print(ms.body())
            | None => env.out.print("ERROR")
          end
          
        end
      else
        env.err.print("error open " + "test.json")
      end
    end
  
