module Msg exposing (..)

import Browser
import Home
import Admin

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | AdminMsg Admin.Msg
    | None