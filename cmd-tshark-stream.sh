#!/bin/bash

./cmd-tshark.sh | nc -C 127.0.0.1 31337
