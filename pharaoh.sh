# logdir=`mktemp -d`
# for host in `read hosts.lst ; do
#       ssh -n -o BatchMode=yes "$host" 'project1/setup.sh' 1>"$logdir/$host.log" 2>&1 &
#    done
#    wait
# done

get_dirname () {
  echo 'run1'
}

many_args () {
  VALS=()
  while [[ $(echo "$1" | cut -c1) != '-' ]]; do
    if [ -z "$1" ]; then
      return
    fi
    VALS+=($1)
    shift
  done
}


script_args () {
  ARGSTRING=''
  while [[ $(echo "$1" | cut -c1) != '-' ]]; do
    if [ -z "$1" ]; then
      # trim leading space
      ARGSTRING=${ARGSTRING:1}
      return
    fi
    if [[ "$1" =~ '=' ]]; then
      flag=`echo $1 | cut -d = -f1`
      val=`echo $1 | cut -d = -f2`
      ARGSTRING+=" --${flag} ${val}"
    else
      ARGSTRING+=" $1"
    fi
    shift
  done
  # trim leading space
  ARGSTRING=${ARGSTRING:1}
}

parse_args () {
  while [[ $# -gt 0 ]]; do
    ARG="$1"

    case $ARG in
      -h | --hosts)

        if [ -f "$2" ]; then
          HOSTS=( $(<"$2") )
        else
          shift
          # set VALS
          many_args $@
          HOSTS=( ${VALS[@]} )
          continue
        fi
        shift 2
      ;;
      -s | --script)
        SCRIPT="$2"
        shift 2
      ;;
      -a | --args)
        shift
        # set ARGSTRING
        script_args $@
        SCRIPTARGS+=( ${ARGSTRING} )
      ;;
      -k | --keyfile)
        KEYFILE="$2"
        shift 2
      ;;
      -d | --dirname)
        DIRNAME='$2'
        shift 2
      ;;
      *)
        continue
      ;;
    esac
  done
}


run_parallel () {

  SCRIPTARGS=()
  parse_args $@

  echo $HOSTS
  echo $SCRIPT
  echo $SCRIPTARGS
  echo $KEYFILE

  N=${#HOSTS[@]}

  if [ ${#ARGS[@]} -ne $N -a ${#ARGS[@]} -ne 0 ]; then
    echo "Number of arguments must be same as number of hosts."
    return 1
  fi

  if [ -z $DIRNAME ]; then
     DIRNAME=`get_dirname`
  fi
  if [ ! -d $DIRNAME ]; then
    mkdir $DIRNAME
  fi


  for i in seq 0 $(( $N - 1 )); do
    host=${HOSTS[$i]}
    user=$(echo $host | cut -d '@' -f 1)
    remote_dir="/home/$user/"
    args=${SCRIPTARGS[$i]}
    scp -i $KEYFILE "$SCRIPT" "${host}:${remote_dir}"
    ssh -i $KEYFILE -n -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$host" "chmod 500 ${remote_dir}$SCRIPT && ${remote_dir}$SCRIPT" ${args} 1>"$DIRNAME/$host.log" 2>&1 &
  done
  wait
}
