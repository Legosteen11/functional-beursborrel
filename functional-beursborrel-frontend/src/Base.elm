module Base exposing (view)

import Browser
import Element exposing (Element)
import Session exposing (Data)
import Msg exposing (Msg(..))

view : Data -> (a -> Msg) -> (String, List (Element a)) -> Browser.Document msg
view session toMsg (title, body) =
    { title = title
    , body =
          [ List.map (Element.map toMsg) body
          ]}