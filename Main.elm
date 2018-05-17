port module Main exposing (..)

import Lib
import UrlParser exposing (..)


main : Program Never Model (Lib.Routed Msg Model)
main =
    Lib.routedPersistentProgram
        { parseRoute = parseRoute
        , route = route
        , init = init
        , subscriptions = subscriptions
        , update = update
        }


type Route
    = Hello
    | HelloPerson String


parseRoute : Parser (Route -> a) a
parseRoute =
    oneOf
        [ map HelloPerson (s "person" </> string)
        , map Hello top
        ]


route : Lib.RequestId -> Route -> Lib.RouteAction Msg Model
route reqId r =
    case r of
        HelloPerson person ->
            Lib.View (greeterView person)

        Hello ->
            Lib.Dispatch (Bump reqId)


type Msg
    = Bump Lib.RequestId


type alias Model =
    Int


init : Model
init =
    0


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd msg )
update msg n =
    case msg of
        Bump reqId ->
            let
                str_ =
                    "re: " ++ reqId
            in
                ( Debug.log str_ (n + 1)
                , Lib.respond { reqId = reqId, response = { status = 200, body = "hello " ++ toString n } }
                )


greeterView : String -> Model -> Lib.Response
greeterView name _ =
    { status = 200, body = "hello " ++ name }
