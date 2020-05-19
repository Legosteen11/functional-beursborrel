module Base exposing (view)

import Browser
import Element exposing (Element, column)
import List
import Session exposing (Data)
import Msg exposing (..)

view : Data -> (a -> Msg) -> (String, List (Element a)) -> Browser.Document Msg
view _ toMsg (title, body) =
    { body = 
        [ Element.layout [] (column [] (List.map (Element.map toMsg) body)) ]
    , title = title
    }