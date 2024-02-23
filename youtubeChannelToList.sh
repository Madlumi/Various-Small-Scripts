#!/bin/sh
######################################################################
# Get all videos from a youtube channel and print them out into      #
# outfile. needs api key and channel id                              #
######################################################################
API_KEY="$YT_API_KEY"
CHANNEL_ID=""
#ex: UCzL0SBEypNk4slpzSbxo01g

fetch_videos() {
    local page_token="$1"
    local api_url="https://www.googleapis.com/youtube/v3/search?key=$API_KEY&channelId=$CHANNEL_ID&part=snippet,id&order=date&maxResults=50&pageToken=$page_token"
    local response=$(curl -s "$api_url")
    echo "$response"
}

parse_response() {
    local response="$1"
    local video_ids=$(echo "$response" | jq -r '.items[].id.videoId')
    local video_titles=$(echo "$response" | jq -r '.items[].snippet.title')
    for i in $(seq 1 $(echo "$video_ids" | wc -l)); do
        local video_id=$(echo "$video_ids" | sed -n "${i}p")
        local video_title=$(echo "$video_titles" | sed -n "${i}p")
        echo "http://youtube.com/watch?v=$video_id [$video_title]"
        echo "http://youtube.com/watch?v=$video_id [$video_title]" >> outfile
    done
    local next_page_token=$(echo "$response" | jq -r '.nextPageToken')
    if [ "$next_page_token" != "null" ]; then
        local next_response=$(fetch_videos "$next_page_token")
        parse_response "$next_response"
    fi
}

initial_response=$(fetch_videos "")
parse_response "$initial_response"
