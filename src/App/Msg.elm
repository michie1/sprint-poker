module App.Msg exposing (Msg(..))

import App.OutsideInfo exposing (InfoForElm)
import Data.User exposing (User)

type Msg
    = Outside InfoForElm
    | OnInputName String
    | SetPoints String
    | Reset
    | RemoveUser String
    | LogErr String
    | Noop
