#!/bin/bash

# TODO - show list of available images for useage
# TODO - argument validate
#        image is present

HELP="NO"
if [ $# -eq 0 ]; then
        HELP="YES"
fi

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -i|--image)
    IMAGE="$2"
    shift
    ;;
    -e|--engine)
    ENGINE="$2"
    shift
    ;;
    -r|--ruleset)
    RULESET="$2"
    shift
    ;;
    -p|--pcap)
    PCAP="$2"
    if [ ! -f /usr/local/etc/dockerIdsEngines/pcaps/"$PCAP" ] ; then
        echo "PCAP FILE NOT FOUND"
        echo "/usr/local/etc/dockerIdsEngines/pcaps/"$PCAP" does not exist"
        exit 1
    fi
    shift
    ;;
    -x|--extra)
    EXTRAS="$2"
    shift
    ;;
    -h|--help)
    HELP="YES"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift
done

# ensure engine is set and a supported engined options are there
if [ -z "$ENGINE" ] ; then
    HELP="YES"
    echo "-e|--engine flag missing"
fi

if [ "$ENGINE" != "snort" ] && [ "$ENGINE" != "suricata" ] ; then
    echo "$ENGINE is not currently supported"
    HELP="YES"
fi

# ensure ruleset is set and is there
if [ -z "$RULESET" ] ; then
    HELP="YES"
    echo "-r|--ruleset flag missing"
fi

if [ ! -d /usr/local/etc/dockerIdsEngines/"$ENGINE"/"$RULESET" ] ; then
    echo "RULESET NOT FOUND"
    echo "Ruleset Directory /usr/local/etc/dockerIdsEngines/"$ENGINE"/"$RULESET" does not exist"
    exit 1
fi

if [[ "$HELP" = "YES" ]] ; then
echo "Usage: $0 -i [image_name] -e [engine] -r [ruleset] -p [pcap] -x [extra options]";
echo "";
echo "-i|--image        image name to use";
echo "-e|--engine       IDS engine to run (currently snort or suricata)";
echo "-r|--ruleset      ruleset name to for which to load the config file";
echo "-p|--pcap packet capture file to read";
echo "-x|--extra        any other options to the IDS engine you'd like ('-k none')";
echo "-h|--help display this helpful information";
echo "";
echo "Everything but -x is required";
echo "";
exit 1;
fi

if [ "$ENGINE" = "snort" ]; then
    docker run --rm -v /usr/local/etc/dockerIdsEngines/"$ENGINE"/"$RULESET":/usr/local/etc/"$ENGINE"/"$RULESET" -v /usr/local/etc/dockerIdsEngines/pcaps/:/tmp/ "$IMAGE" "$ENGINE" -c /usr/local/etc/snort/"$RULESET"/snort.conf -N -r /tmp/"$PCAP" -H -A console "$EXTRAS"
elif [ "$ENGINE" = "suricata" ];  then
        echo 'run suricata'
fi