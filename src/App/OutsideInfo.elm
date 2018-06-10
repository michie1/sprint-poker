port module App.OutsideInfo exposing (sendInfoOutside, InfoForOutside, InfoForOutside(..), InfoForElm, InfoForElm(..), getInfoFromOutside)

import Json.Encode
import Json.Decode exposing (decodeValue)

import Data.User exposing (User, usersDecoder)


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
            infoForOutside { tag = "SetPoints", data = Json.Encode.int points }

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
                                onError e

                    "UsersLoaded" ->
                            case decodeValue usersDecoder outsideInfo.data of
                                Ok users ->
                                    tagger <| Users users

                                Err e ->
                                    onError e

                    "UserRemoved" ->
                        case decodeValue Json.Decode.bool outsideInfo.data of
                            Ok _ ->
                                tagger <| UserRemoved

                            Err e ->
                                onError e
                            
                    _ ->
                        onError <| "Unexpected info from outside: " ++ toString outsideInfo
        )


type InfoForOutside
    = Hi Json.Encode.Value
    | SetName String
    | SetPoints Int
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
