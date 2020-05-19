module Msg exposing (..)

import Browser
import Url
import Drink exposing (DrinkList)
import Http

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotDrinks (Result Http.Error DrinkList)
    | UpdateDrinks
    | HomeMsg
    | AdminMsg
    | None
