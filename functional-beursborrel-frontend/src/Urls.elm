module Urls exposing (baseUrl, adminBaseUrl, drinkUrl, orderUrl)

baseUrl = "http://localhost:8080"
adminBaseUrl = baseUrl ++ "/admin"

-- user
drinkUrl = baseUrl ++ "/drink"


-- admin
orderUrl = adminBaseUrl ++ "/order"
