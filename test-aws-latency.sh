#!/bin/bash

for region in af-south-1 ap-east-1 ap-northeast-1 ap-northeast-2 ap-northeast-3 ap-south-1 ap-south-2 ap-southeast-1 ap-southeast-2 ap-southeast-3 ap-southeast-4 ap-southeast-5 ap-southeast-7 ca-central-1 ca-west-1 cn-north-1 cn-northwest-1 eu-central-1 eu-central-2 eu-north-1 eu-south-1 eu-south-2 eu-west-1 eu-west-2 eu-west-3 il-central-1 me-central-1 me-south-1 mx-central-1 sa-east-1 us-east-1 us-east-2 us-gov-east-1 us-gov-west-1 us-west-1 us-west-2; do 
	echo "Region: ${region}"

	# Array to store response times
	times=()

	# Collect response times
	for i in {1..5}; do
		time=$(curl -w '%{time_total}' -s -o /dev/null "https://dynamodb.${region}.amazonaws.com")
		times+=("$time")
		echo "* Response time: ${time}s"
	done

	# Calculate statistics
	sum=0
	min=${times[0]}
	max=${times[0]}

	for t in "${times[@]}"; do
		sum=$(echo "$sum + $t" | bc -l)
		# Check min and max
		(( $(echo "$t < $min" | bc -l) )) && min=$t
		(( $(echo "$t > $max" | bc -l) )) && max=$t
	done

	# Compute average
	count=${#times[@]}
	avg=$(echo "$sum / $count" | bc -l)

	# Compute standard deviation
	sum_sq_diff=0
	for t in "${times[@]}"; do
		diff=$(echo "$t - $avg" | bc -l)
		sq_diff=$(echo "$diff * $diff" | bc -l)
		sum_sq_diff=$(echo "$sum_sq_diff + $sq_diff" | bc -l)
	done

	stddev=$(echo "sqrt($sum_sq_diff / $count)" | bc -l)

	# Output results
	echo "Average Response Time: ${avg}s"
	echo "Minimum Response Time: ${min}s"
	echo "Maximum Response Time: ${max}s"
	echo "Standard Deviation: ${stddev}s"
	echo
done
