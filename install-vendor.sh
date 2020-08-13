#!/bin/bash

set -e

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

cd $__DIR__

if type cpanm ; then
    echo "ok"
else
    echo "cpanm is required. Please install App::cpanminus from distribution or CPAN"
    exit 1
fi

mkdir -p vendor

cpanm -L vendor --self-contained <requirements.txt
