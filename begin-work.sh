#!/bin/sh

# This script creates a local git repo so you can begin tracking your
# work. It also assigns you a UUID so that your code reviewer won't
# know your identity.

function fail {
    echo $*
    exit 1
}

[ ! -e .git ] ||
    fail "There is already a .git repository here!"

echo "Enter your name, then email address, so we can contact you after"
echo "we review your work."
echo
read -p "Name: " NAME
read -p "Email: " EMAIL

if (( ${#NAME} < 1 || ${#EMAIL} < 6 )); then
    echo
    echo "ABORTED: If you don't provide a real name and email address then"
    echo "we won't be able to contact you!"
    exit 1
fi

UUID=$(uuidgen)

echo
echo "$NAME, you have been assigned UUID $UUID."
echo

SECRET=$(echo "$NAME <$EMAIL>" |
             openssl enc -aes-256-cbc -pass pass:$UUID -base64) ||
    fail "Couldn't scramble identity!"

git init ||
    fail "Couldn't initialize git repository!"

git config --local user.uuid $UUID ||
    fail "Couldn't set user.uuid!"

git config --local user.name ${UUID:0:8} ||
    fail "Couldn't set user.name!"

git config --local user.email "${UUID}@localhost" ||
    fail "Couldn't set user.email!"

git add --all ||
    fail "Couldn't add files to index!"

echo "Initial Commit\n\nIdentity:\n${SECRET}" |
    (git commit --quiet -a -F - || fail "Couldn't create initial commit!")

curl --silent \
     --request PUT --data "" \
     --header "x-amz-acl: bucket-owner-full-control" \
     https://s3.amazonaws.com/logcheck-eval-submissions/$UUID.zip

echo
echo "NOTE: If you have the project open in Xcode, you may need to close"
echo "      and reopen it so that Xcode will notice the repository."
echo
echo "You're all ready to go. Good luck!"
