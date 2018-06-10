module App.Msg exposing (Msg, Msg(..))

import App.OutsideInfo exposing (InfoForElm)


type Msg
    = Outside InfoForElm
    | OnInputName String
    | SetPoints Int
    | Reset
    | LogErr String
    | Noop
