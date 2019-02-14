#!/bin/sh

# This script zips up your work and uploads it to our submission bucket.

if UUID=$(git config user.uuid); then
    echo "Your UUID is $UUID."
    echo
else
    echo "There's no UUID in your git config! Did you run begin-work.sh?"
    exit 1
fi

echo Optimizing git repository...

git gc --quiet --aggressive

echo Archiving files...

ARCHIVE_DIR=$(mktemp -d -t dithering)

ARCHIVE_PATH="${ARCHIVE_DIR}/${UUID}.zip"

if ! zip -q -r "$ARCHIVE_PATH" .; then
    echo "error: failed to create zip archive!"
    exit 1
fi

if [ $(stat -f "%z" "$ARCHIVE_PATH") -lt 5242880 ]
then
    echo Uploading archive...

    curl --fail --progress \
         --upload-file "$ARCHIVE_PATH" \
         --header "x-amz-acl: bucket-owner-full-control" \
         https://s3.amazonaws.com/logcheck-eval-submissions/

    UPLOAD_RESULT=$?
else
    echo "error: archive is too large to upload!"
    UPLOAD_RESULT=1
fi

if ! rm -r "$ARCHIVE_DIR"; then
    echo "warning: unable to delete temporary files: ${ARCHIVE_DIR}"
fi

if [ $UPLOAD_RESULT -eq 0 ]; then
    echo "Success! Your work has been submitted."
else
    echo "Something went wrong during the upload!"
    exit 1
fi

FORM_ID="1FAIpQLSf_Yh1y9PQctSeyLWINSb_DMk5SHmv6X7ZpHf9kiGMRr9eLEQ"
FORM_BASE_URL="https://docs.google.com/forms/d/e/${FORM_ID}/viewform"
FORM_URL="${FORM_BASE_URL}?usp=pp_url&entry.1901176872=${UUID}"

echo Opening post-submission survey...
open $FORM_URL
echo "If the survey doesn't open, you can open it yourself at <${FORM_URL}>"
