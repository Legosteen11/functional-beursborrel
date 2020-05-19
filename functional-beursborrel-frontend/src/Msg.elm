module Msg exposing (..)

import Home
import Url
import Browser

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | None
