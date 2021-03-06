port module App.OutsideInfo exposing (InfoForElm(..), InfoForOutside(..), getInfoFromOutside, sendInfoOutside)

import Data.User exposing (User, usersDecoder)
import Json.Decode exposing (decodeValue)
import Json.Encode


port infoForOutside : GenericOutsideData -> Cmd msg


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


sendInfoOutside : InfoForOutside -> Cmd msg
sendInfoOutside info =
    case info of
        Hi payload ->
            infoForOutside { tag = "Hi", data = payload }

        SetName name ->
            infoForOutside { tag = "SetName", data = Json.Encode.string name }

        SetPoints points ->
            infoForOutside { tag = "SetPoints", data = Json.Encode.string points }

        Reset ->
            infoForOutside { tag = "Reset", data = Json.Encode.bool True }

        RemoveUser uid ->
            infoForOutside { tag = "RemoveUser", data = Json.Encode.string uid }

        LogError err ->
            infoForOutside { tag = "LogError", data = Json.Encode.string err }


getInfoFromOutside : (InfoForElm -> msg) -> (String -> msg) -> Sub msg
getInfoFromOutside tagger onError =
    infoForElm
        (\outsideInfo ->
            case outsideInfo.tag of
                "SignedIn" ->
                    case decodeValue Json.Decode.string outsideInfo.data of
                        Ok id ->
                            tagger <| SignedIn id

                        Err e ->
                            onError "SignedIn error"

                "UsersLoaded" ->
                    case decodeValue usersDecoder outsideInfo.data of
                        Ok users ->
                            tagger <| Users users

                        Err e ->
                            onError "UsersLoaded error"

                "UserRemoved" ->
                    case decodeValue Json.Decode.bool outsideInfo.data of
                        Ok _ ->
                            tagger <| UserRemoved

                        Err e ->
                            onError "UserRemoved error"

                _ ->
                    onError <| "Unexpected info from outside: " ++ Debug.toString outsideInfo
        )


type InfoForOutside
    = Hi Json.Encode.Value
    | SetName String
    | SetPoints String
    | Reset
    | RemoveUser String
    | LogError String


type InfoForElm
    = SignedIn String
    | UserRemoved
    | Users (List User)


type alias GenericOutsideData =
    { tag : String
    , data : Json.Encode.Value
    }
