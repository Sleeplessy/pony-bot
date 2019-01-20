// Managers handles all subscribers and subscriptions
use "collections/persistent"

primitive SubscribeManager


class Subscriber
  var groups: Set[U64]  // subscribed groups
  var persons: Set[U64] // subscribed persons

  new create() =>
    groups = Set[U64].create()
    persons = Set[U64].create()
    
  
  fun is_sub(qq: QQ): Bool =>
      match qq.qq_type()
        | NormalUser =>
        if persons.contains(qq.qq()) then
          true
        else
          false
        end
        | Group =>
        if groups.contains(qq.qq()) then
          true
        else
          false
        end
        
      end    
