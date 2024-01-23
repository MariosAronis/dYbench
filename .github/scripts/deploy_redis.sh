#!/bin/bash

#PSEUDO CODE BELOW THIS LINE

fetch infrastructure details (networks, security groups etc)
deploy ec2
install redis stack or redis server
create an internal dns zone and record to make redis api reachable from clients
configure database


: '
We need to store the following data: 
    - Transactions: Tx Hash :: Tx Submit TimeStamp :: Block Height
'