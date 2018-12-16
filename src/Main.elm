module Main exposing (Model, effortPoints, init, main, showUsers, subscriptions, update, view)

import App.Msg as Msg exposing (Msg)
import App.OutsideInfo
import Data.User exposing (User)
import Html exposing (Html, button, div, h2, input, li, span, text, ul)
import Html.Attributes exposing (value)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Json.Decode as Json
import Browser



type alias Flags =
    {}

-- MODEL


effortPoints : List Int
effortPoints =
    [ 1
    , 2
    , 3
    , 5
    , 8
    , 13
    , 21
    , 34
    ]


type alias Model =
    { name : String
    , uid : Maybe String
    , points : Maybe Int
    , users : Maybe (List User)
    , removed : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { name = "H!ello"
      , uid = Nothing
      , points = Nothing
      , users = Nothing
      , removed = False
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    case ( model.uid, model.users, model.removed ) of
        ( _, _, True ) ->
            div [] [ text "Removed" ]

        ( Just uid, Just users, _ ) ->
            let
                pointsText = case model.points of
                    Just points ->
                        String.fromInt points
                    Nothing ->
                        ""
            in
                div []
                    [ ul []
                    [ li [] [ text model.name ]
                    , li [] [ text uid ]
                    , li [] [ text <| pointsText ]
                    , li [] [ input [ onInput Msg.OnInputName, value model.name ] [] ]
                    ]
                        , div [] <|
                            List.map (\points -> button [ onClick <| Msg.SetPoints points ] [ text (String.fromInt points) ]) effortPoints
                                , button [ onClick Msg.Reset ] [ text "Reset" ]
                                , h2 [] [ text "Users" ]
                                , showUsers users
                                ]

        _ ->
            div [] [ text "Connecting ..." ]


showUsers : List User -> Html Msg
showUsers users =
    let
        noNothingPoints =
            List.length (List.filter (\user -> user.points == Nothing) users) == 0
    in
    ul [] <|
        List.map
            (\user ->
                let
                    points =
                        if noNothingPoints then
                            case user.points of
                                Just val ->
                                    String.fromInt val

                                Nothing ->
                                    "0"

                        else
                            case user.points of
                                Just val ->
                                    "Answered"

                                Nothing ->
                                    "Waiting for answer"
                in
                li []
                    [ span [] [ text (user.name ++ " - " ++ points) ]
                    , span [] [ text " - " ]
                    , button [ onClick <| Msg.RemoveUser user.uid ] [ text "Remove" ]
                    ]
            )
            users



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Noop ->
            ( model, Cmd.none )

        Msg.OnInputName name ->
            let
                cmd =
                    if name == "" then
                        Cmd.none

                    else
                        App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.SetName name
            in
            ( { model | name = name }, cmd )

        Msg.SetPoints points ->
            ( { model | points = Just points }, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.SetPoints points )

        Msg.Reset ->
            ( { model | points = Nothing }, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.Reset )

        Msg.RemoveUser uid ->
            ( model, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.RemoveUser uid )

        Msg.Outside infoForElm ->
            case infoForElm of
                App.OutsideInfo.SignedIn uid ->
                    let
                        name =
                            String.slice 0 5 uid
                    in
                    ( { model | uid = Just uid, name = name }
                    , App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.SetName name
                    )

                App.OutsideInfo.Users users ->
                    let
                        points =
                            case
                                List.head <|
                                    List.filter
                                        (\user ->
                                            model.uid == Just user.uid
                                        )
                                        users
                            of
                                Just user ->
                                    user.points

                                Nothing ->
                                    model.points
                    in
                    ( { model | users = Just users, points = points }, Cmd.none )

                App.OutsideInfo.UserRemoved ->
                    ( { model | removed = True }, Cmd.none )

        Msg.LogErr err ->
            ( model, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.LogError err )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ App.OutsideInfo.getInfoFromOutside Msg.Outside Msg.LogErr ]



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
