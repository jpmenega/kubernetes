#!/usr/bin/env bash

set -o nounset

share() { local share="$1" path="$2" browsable="${3:-yes}" ro="${4:-yes}" \
                guest="${5:-yes}" users="${6:-""}" admins="${7:-""}" \
                writelist="${8:-""}" comment="${9:-""}" file=/etc/samba/smb.conf
	echo $share
	echo $path
}
while getopts ":hc:G:g:i:nprs:Su:Ww:I:" opt; do
    echo $opt
    echo $OPTARG
    echo "========"
    case "$opt" in
        h) usage ;;
        c) charmap "$OPTARG" ;;
        G) eval generic $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        g) global "$OPTARG" ;;
        i) import "$OPTARG" ;;
        n) NMBD="true" ;;
        p) PERMISSIONS="true" ;;
        r) recycle ;;
        s) eval share $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        S) smb ;;
        u) eval user $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        w) workgroup "$OPTARG" ;;
        W) widelinks ;;
        I) include "$OPTARG" ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))
