#!/bin/sh

# This script runs the Checker Framework's signature inference
# iteratively on a program, adding type annotations to the program, until the
# .jaif files from one iteration are the same as the .jaif files from the
# previous iteration (which means there is nothing new to infer anymore).

# To use this script, the $CHECKERFRAMEWORK variable must be set to the
# Checker Framework's directory. Also, insert-annotations-to-source must
# be available from the $PATH.

# This script receives as arguments:
# 1. Processor's name (in any form recognized by CF's javac -processor argument).
# 2. Classpath (target project's classpath).
# 3. Any number of extra processor arguments to be passed to the checker.
# 4. List of paths to .jaif files -- used as input (optional).
# 5. List of paths to .java files in a program.

# Example of usage:
# ./infer-and-annotate.sh "LockChecker,NullnessChecker" \
#     $JSR308/plume-lib/java/plume.jar -AprintErrorStack \
#     `find $JSR308/plume-lib/java/src/plume/ -name "*.java"`

# In case of using this script for Android projects, the classpath must include
# paths to: android.jar, gen folder, all libs used, source code folder.
# The Android project must be built with "ant debug" before running this script.

# TODO: This script deletes all .unannotated files, including ones that could
# have been generated previously by another means other than using this script.
# We must decide if we want to make a backup of previously generated
# .unannotated files, or if we want to keep the first set of generated
# .unannotated files.

# Halts the script when a nonzero value is returned from a command.
set -e

# Path to directory that will contain .jaif files after running the CF
# with -AinferSignatures
SIGNATURE_INFERENCE_DIR=build/signature-inference

# Path that will contain .class files after running CF's javac. This dir will
# be deleted after executing this script.
TEMP_DIR=build/temp-signature-inference-output

# Path to directory that will contain .jaif files from the previous iteration.
PREV_ITERATION_DIR=build/prev-signature-inference

# Path to annotation-file-utilities.jar
AFU_JAR="${CHECKERFRAMEWORK}/../annotation-tools/annotation-file-utilities/annotation-file-utilities.jar"

debug=
# For debugging
# debug=1

# This function separates extra arguments passed to the checker from Java files
# received as arguments.
# TODO: Handle the following limitation: This function makes the assumption
# that every argument starts with a hyphen. It means one cannot pass arguments
# such as -processorpath and -source, which are followed by a value.
read_input() {
    processor=$1
    cp=$2:$AFU_JAR
    # Ignores first two arguments (processor and cp).
    shift
    shift
    extra_args=""
    java_files=""
    jaif_files=""
    for i in "$@"
    do
        # This function makes the assumption that every extra argument
        # starts with a hyphen. The rest are .java/.jaif files.
        case "$1" in
            -*)
                extra_args="$extra_args $1"
            ;;
            *.jaif)
                jaif_files="$jaif_files $1"
            ;;
            *.java)
                java_files="$java_files $1"
            ;;
        esac
        shift
    done
}

# Iteratively runs the Checker
infer_and_annotate() {
    mkdir -p $TEMP_DIR
    DIFF_JAIF=firstdiff
    # Create/clean signature-inference directory.
    rm -rf $SIGNATURE_INFERENCE_DIR
    mkdir -p $SIGNATURE_INFERENCE_DIR
    # If there are .jaif files as input, copy them.
    for file in $jaif_files;
    do
        cp $file $SIGNATURE_INFERENCE_DIR/
    done

    # Perform inference and add annotations from .jaif to .java files until
    # $PREV_ITERATION_DIR has the same contents as $SIGNATURE_INFERENCE_DIR.
    while [ "$DIFF_JAIF" != "" ]
    do
        # Updates $PREV_ITERATION_DIR folder
        rm -rf $PREV_ITERATION_DIR
        mv $SIGNATURE_INFERENCE_DIR $PREV_ITERATION_DIR

        # Runs CF's javac
        command="${CHECKERFRAMEWORK}/checker/bin/javac -d $TEMP_DIR/ -cp $cp -processor $processor -AinferSignatures -Awarns -Xmaxwarns 10000 $extra_args $java_files"
        if [ $debug ]; then
            echo ${command}
            echo "Press any key to run command... "
            read _
        fi
        ${command} || true
        # Deletes .unannotated backup files. This is necessary otherwise the
        # insert-annotations-to-source tool will use this file instead of the
        # updated .java one.
        # See TODO about .unannotated file at the top of this file.
        for file in $java_files;
        do
            rm -f "${file}.unannotated"
        done
        if [ ! `find $SIGNATURE_INFERENCE_DIR -prune -empty` ]
        then
            # Only insert annotations if there is at least one .jaif file.
            insert-annotations-to-source -i `find $SIGNATURE_INFERENCE_DIR -name "*.jaif"` $java_files
        fi
        # Updates DIFF_JAIF variable.
        # diff returns exit-value 1 when there are differences between files.
        # When this happens, this script halts due to the "set -e"
        # in its header. To avoid this problem, we add the "|| true" below.
        DIFF_JAIF="$(diff -qr $PREV_ITERATION_DIR $SIGNATURE_INFERENCE_DIR || true)"
    done
    clean
}

clean() {
    # It might be good to keep the final .jaif files.
    # rm -rf $SIGNATURE_INFERENCE_DIR
    rm -rf $PREV_ITERATION_DIR
    rm -rf $TEMP_DIR
    # See TODO about .unannotated file at the top of this file.
    for file in $java_files;
        do
            rm -f "${file}.unannotated"
    done
}

# Main
if [ "$#" -lt 3 ]; then
    echo "Aborting infer-and-annotate.sh: Expected at least 3 arguments. Check the script's documentation."
    echo "Received the following arguments: $@."
    exit 1
fi

read_input "$@"
infer_and_annotate
