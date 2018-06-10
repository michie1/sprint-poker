module Main exposing (..)

import Html exposing (Html, div, h2, text, program, input, button, ul, li)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onClick, on, targetValue)
import Json.Decode as Json
import App.OutsideInfo
import App.Msg as Msg exposing (Msg)
import Data.User exposing (User)


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
    }


init : ( Model, Cmd Msg )
init =
    ( { name = "H!ello"
      , uid = Nothing
      , points = Nothing
      , users = Nothing
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    case ( model.uid, model.users ) of
        ( Just uid, Just users ) ->
            div []
                [ ul []
                    [ li [] [ text model.name ]
                    , li [] [ text uid ]
                    , li [] [ text <| toString model.points ]
                    , li [] [ input [ onInput Msg.OnInputName, value model.name ] [] ]
                    ]
                , div [] <|
                    List.map (\points -> button [ onClick <| Msg.SetPoints points ] [ text (toString points) ]) effortPoints
                , button [ onClick Msg.Reset ] [ text "Reset" ]
                , h2 [] [ text "Users" ]
                , showPoints users
                ]

        _ ->
            div [] [ text "Connecting ..." ]


showPoints : List User -> Html Msg
showPoints users =
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
                                        toString val

                                    Nothing ->
                                        "0"
                            else
                                case user.points of
                                    Just val ->
                                        "Answered"

                                    Nothing ->
                                        "Waiting for answer"
                    in
                        li [] [ text (user.name ++ " - " ++ points) ]
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
                newName =
                    if name == "" then
                        case model.uid of
                            Just uid ->
                                uid

                            Nothing ->
                                ""
                    else
                        name
            in
                ( { model | name = newName }, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.SetName newName )


        Msg.SetPoints points ->
            ( { model | points = Just points }, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.SetPoints points )

        Msg.Reset ->
            ( { model | points = Nothing }, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.Reset )

        Msg.Outside infoForElm ->
            case infoForElm of
                App.OutsideInfo.SignedIn uid ->
                    ( { model | uid = Just uid, name = uid }, Cmd.none )

                App.OutsideInfo.ByeLoaded value ->
                    let
                        _ =
                            Debug.log "3bye loaded" value
                    in
                        ( model, Cmd.none )

                App.OutsideInfo.Users users ->
                    let
                        points =
                            case
                                (List.head <|
                                    List.filter
                                        (\user ->
                                            model.uid == (Just user.uid)
                                        )
                                        users
                                )
                            of
                                Just user ->
                                    user.points

                                Nothing ->
                                    model.points
                    in
                        ( { model | users = Just users, points = points }, Cmd.none )

        Msg.LogErr err ->
            ( model, App.OutsideInfo.sendInfoOutside <| App.OutsideInfo.LogError err )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ App.OutsideInfo.getInfoFromOutside Msg.Outside Msg.LogErr ]



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
