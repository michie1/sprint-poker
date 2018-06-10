module App.Msg exposing (Msg, Msg(..))

import App.OutsideInfo exposing (InfoForElm)
import Data.User exposing (User)


type Msg
    = Outside InfoForElm
    | OnInputName String
    | SetPoints Int
    | Reset
    | RemoveUser String
    | LogErr String
    | Noop
