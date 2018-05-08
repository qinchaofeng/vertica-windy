#!/bin/sh

if [ -z "$VSQL" ] ; then
  VSQL="/opt/vertica/bin/vsql -e"
fi
VSQL_F=`sed s/-a// <<<$VSQL`; VSQL_F=`sed s/-e// <<<$VSQL_F`

##################################################
#  parameters
#
usage(){
  cat <<-EOF
Parameters:
$(set | grep design | awk '{print "  "$0}')
Usage: $(basename ${0})
  -n designName
  [-q designQueryFile=]
  [-c designAnalyzeCorrelationsMode=0]
       0—When creating a design, ignore any column correlations in the specified tables.
       1—Consider the existing correlations in the tables when creating the design. If you set the mode to 1, and there are no existing correlations, Database Designer does not consider correlations.
       2—Analyze column correlations on tables where the correlation analysis was not previously performed. When creating the design, consider all column correlations (new and existing).
       3—Analyze all column correlations in the tables and consider them when creating the design. Even if correlations exist for a table, reanalyze the table for correlations.
  [-s designAnalyzeStatistics=false]
  [-d designDeploy=false]
  [-k designKSafety=1]: can be 0, 1, 2
  [-o designOptimizationObjective=BALANCED]: can be BALANCED, QUERY, LOAD
  [-p designOutputDir=default is current directory]
  [-t designTables=*]: Comma-delimited list of tables.The table_pattern must be one of the following:
       '*' indicates to add all user tables in the current database.
       '<schema>.*' indicates to add all tables in the specified schema.
       '<schema>.<table>' indicates to add the specified table in the specified schema.
       '<table>' indicates the specified table in the current search path.
  [-T designType=COMPREHENSIVE]: can be COMPREHENSIVE, INCREMENTAL
	EOF
  exit 1
}

while getopts "h n:q:c:s:d:k:o:p:t:T:" options; do
	case $options in
		n ) designName="$OPTARG";;
		q ) designQueryFile="$OPTARG";;
		c ) designAnalyzeCorrelationsMode="$OPTARG";;
		s ) designAnalyzeStatistics="$OPTARG";;
		d ) designDeploy="$OPTARG";;
		k ) designKSafety="$OPTARG";;
		o ) designOptimizationObjective="$OPTARG";;
		p ) designOutputDir="$OPTARG";;
		t ) designTables="$OPTARG";;
		T ) designType="$OPTARG";;
		h ) usage;;
		? ) usage;;
		* ) usage;;
	esac
done;

if [ -z "$designName" ] ; then
  usage
  exit 1
fi

# designOutputDir: default is current directory
if [ -z "$designOutputDir" ] ; then
  designOutputDir=$(pwd)
fi

# designTables: # Comma-delimited list of tables, type VARCHAR. The table_pattern must be one of the following:
#    '*' indicates to add all user tables in the current database.
#    '<schema>.*' indicates to add all tables in the specified schema.
#    '<schema>.<table>' indicates to add the specified table in the specified schema.
#    '<table>' indicates the specified table in the current search path.
if [ -z "$designTables" ] ; then
  tables=( `$VSQL_F -XAtq -c "select schema_name||'.*' from schemata where not is_system_schema;" | tr "\\r\\n" " "` )
  designTables=$(IFS=","; echo "${tables[*]}")
fi

# designQueryFile="/opt/vertica/examples/VMart_Schema/vmart_queries.sql"

# designType: COMPREHENSIVE, INCREMENTAL
if [ -z "$designType" ] ; then
  designType="COMPREHENSIVE"
fi

# designOptimizationObjective: BALANCED, QUERY, LOAD
if [ -z "$designOptimizationObjective" ] ; then
  designOptimizationObjective="BALANCED"
fi

# designKSafety: 0, 1, 2
if [ -z "$designKSafety" ] ; then
  designKSafety=`$VSQL_F -XAtq -c "select case when count(*) >= 3 then 1 else 0 end from nodes;" `
fi

# designAnalyzeCorrelationsMode:
#    0—(Default) When creating a design, ignore any column correlations in the specified tables.
#    1—Consider the existing correlations in the tables when creating the design. If you set the mode to 1, and there are no existing correlations, Database Designer does not consider correlations.
#    2—Analyze column correlations on tables where the correlation analysis was not previously performed. When creating the design, consider all column correlations (new and existing).
#    3—Analyze all column correlations in the tables and consider them when creating the design. Even if correlations exist for a table, reanalyze the table for correlations.
if [ -z "$designAnalyzeCorrelationsMode" ] ; then
  designAnalyzeCorrelationsMode=0
fi

# designAnalyzeStatistics: true, false
if [ -z "$designAnalyzeStatistics" ] ; then
  designAnalyzeStatistics=false
fi

# designDeploy: true, false
if [ -z "$designDeploy" ] ; then
  designDeploy=false
fi


designOutputDir=$(cd "${designOutputDir}"; pwd)
mkdir -p ${designOutputDir}

logFile=${designOutputDir}/${designName}_designer.log

##################################################
echo DESIGN [${designName}] begin...
echo Back up any existing design
$VSQL <<-EOF 2>&1 | tee -a ${logFile}
  select export_catalog('${designOutputDir}/${designName}_ddlbackup.sql','DESIGN_ALL');
EOF

echo Cancel any running design[${designName}], delete all its contents.
$VSQL <<-EOF 2>/dev/null | tee -a ${logFile}
  SELECT DESIGNER_CANCEL_POPULATE_DESIGN ('${designName}');
  SELECT DESIGNER_DROP_DESIGN ('${designName}');
EOF

$VSQL <<-EOF 2>&1 | tee -a ${logFile}
  select designer_create_design('${designName}');
  select designer_add_design_tables('${designName}','${designTables}');
  select designer_set_design_type('${designName}','${designType}');
  select designer_set_design_ksafety('${designName}', ${designKSafety});
  select designer_set_optimization_objective('${designName}', '${designOptimizationObjective}');
  select designer_set_analyze_correlations_mode('${designName}',${designAnalyzeCorrelationsMode});
EOF

if [ ! -z "$designQueryFile" ] ; then
	$VSQL <<-EOF 2>&1 | tee -a ${logFile}
	  select designer_add_design_queries('${designName}','${designQueryFile}','true');
	EOF
fi

echo Wait for DESIGN [${designName}] to finish...
$VSQL <<-EOF 2>&1 | tee -a ${logFile}
	select designer_run_populate_design_and_deploy('${designName}',
	  '${designOutputDir}/${designName}_design.sql',
	  '${designOutputDir}/${designName}_deploy.sql',
	  '${designAnalyzeStatistics}', '${designDeploy}',
	  'true',		-- drop_design_workspace
	  'false');		-- do not continue_after_error

	select designer_wait_for_design('${designName}');
EOF

echo DESIGN [${designName}] is done.
