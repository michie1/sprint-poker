module Data.User exposing (User, usersDecoder)

import Json.Decode

type alias User =
    { name : String
    }

userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map
        User
        (Json.Decode.field "name" Json.Decode.string)

usersDecoder : Json.Decode.Decoder (List User)
usersDecoder =
    Json.Decode.list userDecoder
