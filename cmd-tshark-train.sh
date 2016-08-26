#!/bin/bash

./cmd-tshark.sh > train/trainData.txt
chown emdeha:emdeha -R train
