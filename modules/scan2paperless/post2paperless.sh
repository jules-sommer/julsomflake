postdoc() {
  while [[ $# -gt 0 ]]; do
    data="@${1}"
    retval=$(curl --retry 99 --retry-all-errors --http1.1 -f -X POST \
      -H "Authorization: Basic $creds" \
      --form "document=$data" \
      -sS "https://$hostname/api/documents/post_document/" || exit 1)

    if [[ "$retval" == '"OK"' ]]; then
      echo "WARNING: posting data was successful. This does not mean the file was properly imported. Do your checks before deleting data" >&2
      shift
    else
      status="unknown"
      while [[ $status != "SUCCESS" ]] && [[ $status != "FAILURE" ]]; do
        taskinfo=$(curl --retry 99 --retry-all-errors --http1.1 -f -X GET \
          -H "Authorization: Basic $creds" \
          -sS "https://${hostname}/api/tasks/?task_id=${retval//\"/}" || exit 1)
        status=$(jq -r '.[].status' <<< "$taskinfo")

        if [[ $status == "SUCCESS" ]]; then
          echo "Document uploaded as https://${hostname}/documents/$(jq -r '.[].related_document' <<< "$taskinfo")"
          shift
        elif [[ $status == "FAILURE" ]]; then
          echo "failed to upload document $data"
          jq -r '.[].result' <<< "$taskinfo"
          exit 1
        else
          sleep 1
        fi
      done
    fi
  done
}

if [[ $# -eq 0 ]]; then
  postdoc "-"
else
  postdoc "$@"
fi
