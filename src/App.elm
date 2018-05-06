module App exposing (..)

import Html exposing (Html, div, text, program, input, button, ul, li)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onClick)


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
    , points : Maybe Int
    }


init : ( Model, Cmd Msg )
init =
    ( { name = "Hello", points = Nothing }, Cmd.none )



-- MESSAGES


type Msg
    = NoOp
    | SetName String
    | SetPoints Int
    | Reset



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ ul []
            [ li [] [ text model.name ]
            , li [] [ text <| toString model.points ]
            , li [] [ input [ onInput SetName, value model.name ] [] ]
            ]
        , div [] <|
            List.map (\points -> button [ onClick <| SetPoints points ] [ text (toString points) ]) effortPoints
        , button [ onClick Reset ] [ text "Reset" ]
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetName name ->
            ( { model | name = name }, Cmd.none )

        SetPoints points ->
            ( { model | points = Just points }, Cmd.none )

        Reset ->
            ( { model | points = Nothing }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
