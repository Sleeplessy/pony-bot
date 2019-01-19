// Below describes infos needed for a QQ user

primitive NormalUser
  
primitive Group

type QQType is (NormalUser | Group)

// The sexual field
primitive Male

primitive Female
    
type Sexual is (Male | Female)


trait HasID
  fun qq() : U64 => 0  // 0 stands for an invalid person
    
trait HasNick
  fun nick() : String => "" // Defalut as none

trait HasSexual
  fun sex() : (Sexual|None) => None

  
type ValidQQ is (HasID & HasNick & HasSexual)


class QQ is ValidQQ
  let _qq: U64
  var _nick: String
  var _sex: (Sexual|None)
  var _type: QQType
  
  new create(qq': U64, nick': String = "", sex': (Sexual|None) = None, type':QQType = NormalUser) =>
    _qq = qq'
    _nick = nick'
    _sex = sex'
    _type = type'

  fun qq() : U64 => _qq

  fun nick() : String => _nick

  fun sex() : (Sexual | None) => _sex

  fun qq_type() : QQType => _type

  fun ref set_nick(nick': String) => _nick = nick'

  fun ref set_sex(sex': Sexual) => _sex = sex'
