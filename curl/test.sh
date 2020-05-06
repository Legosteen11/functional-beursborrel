#!/bin/bash

case $1 in
    insdrink)
        curl -s -d "@insert_hertog_jan.json" -X POST -H "Content-Type: application/json" http://localhost:8080/admin/drink | jq '.'
        curl -s -d "@insert_wine.json" -X POST -H "Content-Type: application/json" http://localhost:8080/admin/drink | jq '.'
        ;;
    getdrink)
        if [ -z $2 ]; then
            curl -s http://localhost:8080/drink | jq '.'
        else
            curl -s http://localhost:8080/drink/$2 | jq '.'
        fi
        ;;
    order)
        curl -s -d "@order_1.json" -X POST -H "Content-Type: application/json" http://localhost:8080/admin/order | jq '.'
        ;;
    *)  echo "./echo.sh <OPTION>"
        echo "OPTION:"
        echo -e "insdrink"
        echo -e "\tInsert a few drinks"
        echo -e "getdrink"
        echo -e "\tGet all drinks"
        echo -e "getdrink <id>"
        echo -e "\tGet drink with <id>"
        echo -e "order"
        echo -e "\tPlace an order"
        ;;
esac