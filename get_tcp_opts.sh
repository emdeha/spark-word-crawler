cat tcpopts.csv | grep tcp.analysis | grep -v 'Expert Info' | cut -d, -f1 | sed 's/^ */-e/;s/ *$//' | tr '\n' ' 
