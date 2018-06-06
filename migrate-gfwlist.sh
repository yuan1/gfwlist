#!/bin/bash

# This script decodes the base64 encoded GFWList and migrates it's git
# revision history to a new git repository.
# Author: Meiyo Peng
# License: GPLv3
# Copyright 2017 Meiyo Peng


SRC_REPO=../gfwlist-base64
DST_REPO=.
since="2000-01-01 00:00:00 +0000"

# get git revision history
revision_log=$(git -C $SRC_REPO log --reverse --format="%H|%an <%ae>|%ai|%s" --since "$since")

IFS='|'
while read hash author date subject; do
    # some old commit messages are base64 encoded
    if echo $subject | base64 -d >/dev/null; then
        subject=$(echo $subject | base64 -d)
    fi
    # decode gfwlist.txt
    git -C $SRC_REPO show $hash:gfwlist.txt | base64 -d >$DST_REPO/gfwlist.txt
    # add to new repository
    git -C $DST_REPO add gfwlist.txt
    git -C $DST_REPO commit --allow-empty-message --no-gpg-sign --author $author --date $date --message "$subject"
done <<<$revision_log
