#!/bin/sh

DAG=$(dirname "$0")
kvmd-pstrun -- make -C "$DAG"
