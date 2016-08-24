#!/bin/bash

tshark -etcp.analysis -etcp.analysis.ack_rtt -etcp.analysis.acks_frame -etcp.analysis.bytes_in_flight -etcp.analysis.duplicate_ack -etcp.analysis.duplicate_ack_frame -etcp.analysis.duplicate_ack_num -etcp.analysis.flags -etcp.analysis.initial_rtt -etcp.analysis.rto -etcp.analysis.rto_frame -Tfields -Eseparator=, | nc -C 127.0.0.1 31337
