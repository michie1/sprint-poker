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

        LogError err ->
            infoForOutside { tag = "LogError", data = Json.Encode.string err }


getInfoFromOutside : (InfoForElm -> msg) -> (String -> msg) -> Sub msg
getInfoFromOutside tagger onError =
    infoForElm
        (\outsideInfo ->
                case outsideInfo.tag of
                    "Bye" ->
                        case decodeValue Json.Decode.string outsideInfo.data of
                            Ok value ->
                                    tagger <| ByeLoaded value

                            Err e ->
                                onError e

                    "SignedIn" ->
                        case decodeValue Json.Decode.string outsideInfo.data of
                            Ok id ->
                                tagger <| SignedIn id

                            Err e ->
                                onError e

                    "UsersLoaded" ->
                        let
                            _ = Debug.log "hoi3" (decodeValue usersDecoder outsideInfo.data)
                        in
                            case decodeValue usersDecoder outsideInfo.data of
                                Ok users ->
                                    tagger <| Users users

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
    | LogError String


type InfoForElm
    = ByeLoaded String
    | SignedIn String
    | Users (List User)

type alias GenericOutsideData =
    { tag : String
    , data : Json.Encode.Value
    }
