module Data.User exposing (User, usersDecoder)

import Json.Decode
import Json.Decode.Pipeline


type alias User =
    { name : String
    , points : Maybe String
    , uid : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.succeed User
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.optional "points" (Json.Decode.nullable Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "uid" Json.Decode.string


usersDecoder : Json.Decode.Decoder (List User)
usersDecoder =
    Json.Decode.list userDecoder
