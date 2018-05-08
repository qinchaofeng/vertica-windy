# Vertica 8.1.0
kafka_config=" --config-schema kafka_date_dimension --dbhost v001 --username dbadmin --password vertica"

# shutdown instance
/opt/vertica/packages/kafka/bin/vkconfig shutdown --instance-name load_date_dimension_scheduler ${kafka_config}
echo "Shutdown Instance Complete!"
# truncate table
$VSQL <<- EOF
drop schema kafka_date_dimension cascade;
truncate table public.date_dimension;
EOF

# Create and Configure Scheduler
/opt/vertica/packages/kafka/bin/vkconfig scheduler --create --add ${kafka_config} --frame-duration '00:00:10' --eof-timeout-ms 3000 --operator dbadmin
echo "Create and Configure Scheduler Complete!"

# Create a Cluster
/opt/vertica/packages/kafka/bin/vkconfig cluster --create --cluster kafka_cluster --hosts v001:9092 ${kafka_config}
echo "Create Cluster Complete!"

# Create a Data Table


# Create a Source
/opt/vertica/packages/kafka/bin/vkconfig source --create --source date_dimension  --cluster kafka_cluster --partitions 1 ${kafka_config}
echo "Create Kafka Source Complete!"

# Create a Target
/opt/vertica/packages/kafka/bin/vkconfig target --create --target-schema public --target-table date_dimension ${kafka_config}
echo "Create Target Complete!"

# Create a Load-Spec
/opt/vertica/packages/kafka/bin/vkconfig load-spec --create --load-spec load_date_dimension_spec --parser KafkaJSONParser --parser-parameters flatten_arrays=False,flatten_maps=False ${kafka_config}
#/opt/vertica/packages/kafka/bin/vkconfig load-spec --create --load-spec load_date_dimension_spec --parser KafkaJSONParser --filters "FILTER KafkaInsertDelimiters(delimiter=E'\n')" ${kafka_config}

echo "Create Load-Spec Complete!"

# Create a Microbatch
/opt/vertica/packages/kafka/bin/vkconfig microbatch --create --microbatch date_dimension --target-schema public --target-table date_dimension --rejection-schema public --rejection-table date_dimension_rej --load-spec load_date_dimension_spec --add-source date_dimension --add-source-cluster kafka_cluster ${kafka_config}
echo "Create Microbatch Complete!"

# Launch the Scheduler
/opt/vertica/packages/kafka/bin/vkconfig launch --instance-name load_date_dimension_scheduler ${kafka_config} &
echo "Launch the Scheduler Complete!"
echo "Done!"
