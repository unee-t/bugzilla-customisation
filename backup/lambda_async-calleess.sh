#!/bin/bash
sql=dev-backup-2019-08-13.sql
grep -n lambda_async $sql | while read line _
do
	head -n $(echo $line |cut -f1 -d":") $sql | grep PROCEDURE | tail -n1
done
