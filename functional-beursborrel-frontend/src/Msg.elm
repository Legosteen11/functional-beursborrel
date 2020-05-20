module Msg exposing (..)

import Home
import Admin
import Url
import Browser

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | AdminMsg Admin.Msg
    | None
