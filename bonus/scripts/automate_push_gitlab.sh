#!/bin/bash

GITLAB_URL="http://localhost:8080"
USERNAME="root"
PASSWORD="your_root_password"

# Login and get session cookie
curl -c cookies.txt -s -X POST "$GITLAB_URL/users/sign_in" \
  -d "user[login]=$USERNAME&user[password]=$PASSWORD" \
  -H "Content-Type: application/x-www-form-urlencoded"
