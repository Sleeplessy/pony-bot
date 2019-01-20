use "files"
use "websocket"
use "http"
use "encode/base64"




actor Main

  
  new create(env: Env) =>
  """
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
  """  
    try
      let listener = WebSocketListener(
        env.root as AmbientAuth,recover ListenNotify(env) end, "0.0.0.0", "8888")
    end

    
    //let transfer = MessageTransfer("http://127.0.0.1:5700/", env)
    //transfer.send(msg)

    
