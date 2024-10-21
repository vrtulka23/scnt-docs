#!/usr/bin/env bash

set -e

. settings.env
DIR_ROOT=$(pwd)

function build_docs {
    sphinx-build -M html source/ build/
}

function show_help {
    echo "Physical Units and Quantities"
    echo ""
    echo "Options:"
    echo " -b|--build          build documentation"
    echo " -h|--help           show this help"
    echo ""
    echo "Examples:"
    echo "./setup.sh -h                  show this help"
    echo "./setup.sh -b                  build documentation"
}

if [[ "${1}" == "" ]]; then
    show_help
fi
while [[ $# -gt 0 ]]; do
    case $1 in
	-b|--build)
	    build_docs; shift;;
	-h|--help)
	    show_help; shift;;
	*)
	    show_help; shift;;
    esac
done
