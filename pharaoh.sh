# logdir=`mktemp -d`
# for host in `read hosts.lst ; do
#       ssh -n -o BatchMode=yes "$host" 'project1/setup.sh' 1>"$logdir/$host.log" 2>&1 &
#    done
#    wait
# done

function run_parallel {
  HOSTFILE=${1}
  shift
  SCRIPT=${1}
  shift
  ARGS=( $@ )

  echo $HOSTFILE
  echo $SCRIPT
  echo $ARGS

  OLDIFS=${IFS}
  IFS=$'\n'
  HOSTS=( `<$HOSTFILE` )
  IFS=$OLDIFS

  N=${#HOSTS[@]}

  if [ ${#ARGS[@]} -ne $N -a ${#ARGS[@]} -ne 0 ]; then
    echo "Number of arguments must be same as number of hosts."
    return 1
  fi

  DIR='run1'
  if [ ! -d $DIR ]; then
    mkdir $DIR
  fi


  for i in seq 0 $(( $N - 1 )); do
    host=${HOSTS[$i]}
    user=$(echo $host | cut -d '@' -f 1)
    remote_dir="/home/$user/"
    arg=${ARGS[$i]}
    scp -i ~/.ssh/amazon.pem "$SCRIPT" "${host}:${remote_dir}"
    ssh -i ~/.ssh/amazon.pem -n -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$host" "chmod 700 ${remote_dir}$SCRIPT && ${remote_dir}$SCRIPT" "${ARGS[@]}" 1>"$DIR/$host.log" 2>&1 &
  done
  wait
}
