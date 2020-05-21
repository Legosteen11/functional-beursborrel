module Base exposing (view)

import Browser
import Element exposing (Element, column, text)
import Element.Input exposing (button)
import List
import Admin
import Session exposing (Data)
import Msg exposing (Msg(..))

view : Data -> (a -> Msg) -> (String, List (Element a)) -> Browser.Document Msg
view _ toMsg (title, body) =
    { body = 
        [ Element.layout [] 
         (column [] (contentList toMsg body))
        ]
    , title = title
    }


contentList : (a -> Msg) -> List (Element a) -> List (Element Msg)
contentList toMsg body =
    List.map (Element.map toMsg) body ++ [button [] { onPress = Just (Msg.AdminMsg Admin.Update), label = text "Go to admin panel" } ]


