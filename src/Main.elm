module Main exposing (..)

import Html exposing (Html, div, h2, text, program, input, button, ul, li)
import Html.Attributes exposing (value)
import Html.Events exposing (onBlur, onClick, on, targetValue)
import Json.Decode as Json
import App.OutsideInfo
import App.Msg as Msg exposing (Msg)
import Data.User exposing (User)


onBlurWithTargetValue : (String -> msg) -> Html.Attribute msg
onBlurWithTargetValue tagger =
    on "blur" (Json.map tagger targetValue)



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
                    , li [] [ input [ onBlurWithTargetValue Msg.SetName, value model.name ] [], button [] [ text "set name" ] ]
                    ]
                , div [] <|
                    List.map (\points -> button [ onClick <| Msg.SetPoints points ] [ text (toString points) ]) effortPoints
                , button [ onClick Msg.Reset ] [ text "Reset" ]
                , h2 [] [ text "Users" ]
                , ul [] <| List.map (\user -> li [] [ text user.name ]) users
                ]

        _ ->
            div [] [ text "Connecting ..." ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Noop ->
            ( model, Cmd.none )

        Msg.SetName name ->
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
            ( { model | points = Just points }, Cmd.none )

        Msg.Reset ->
            ( { model | points = Nothing }, Cmd.none )

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
                    ( { model | users = Just users }, Cmd.none )

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
