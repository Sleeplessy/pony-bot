// Below describes infos needed for a QQ user

primitive NormalUser
  
primitive Group

type QQType is (NormalUser | Group)

// The sexual field
primitive Male

primitive Female
    
type Sexual is (Male | Female)


trait HasID
  fun ref qq() : U64 => 0  // 0 stands for an invalid person
    
trait HasNick
  fun ref nick() : String => "" // Defalut as none

trait HasSexual
  fun ref sex() : (Sexual|None) => None

  
type ValidQQ is (HasID & HasNick & HasSexual)


class QQ is ValidQQ
  let _qq: U64
  var _nick: String
  var _sex: (Sexual|None)
  var _type: QQType
  var _card: String = ""
  new create(qq': U64, nick': String = "", sex': (Sexual|None) = None, type':QQType = NormalUser) =>
    _qq = qq'
    _nick = nick'
    _sex = sex'
    _type = type'

  fun ref qq(): U64 => _qq

  fun ref nick(): String => _nick

  fun ref sex(): (Sexual | None) => _sex

  fun ref qq_type(): QQType => _type

  fun ref card(): String => _card

  fun ref set_nick(nick': String) => _nick = nick'

  fun ref set_sex(sex': Sexual) => _sex = sex'

  fun ref set_card(card': String) => _card = card'
