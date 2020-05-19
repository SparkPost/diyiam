#!/bin/bash
# Functions used by deploy to run hooks before terraform is called

# Main entry point. call with deploy_hooks ACTION DIR1 DIR2 DIR3 ... 
# Where directories will be searched for hooks to run, based on the ACTION.
deploy_hooks() {
    local -i returncode
    action=$1
    shift
    for arg
    do
      run_hooks "$action" "$arg"
      returncode=$?
      [ $returncode -eq 0 ] || return $returncode
    done
}

# This will run all hooks in $basedir (second argument to this function)
# If any hook fails, return the error from the hook.
run_hooks() {
    local -i exitcode
    action=$1
    basedir=$2
    actiondir=${basedir}/hooks/${action}.d
    # Look for the hook directory
    if [ ! -d "$actiondir" ]
    then
        [ -z "$DEPLOY_DEBUG" ] || echo "No hooks to run for $action (no '$actiondir' directory)" >&2
        return 0
    fi
    # Run all hooks in the hook directory
    for hook in "$actiondir"/*.sh
    do
        [ -x "$hook" ] || {
            echo "$hook" is not executable >&2
            continue
        }
        [ -z "$DEPLOY_DEBUG" ] || echo "Running '$hook'" >&2
        $hook >&2
        exitcode=$?
        if [ $exitcode -ne 0 ]
        then
            echo "Hook '$hook' failed with exit code $exitcode. Bailing" >&2
            return $exitcode
        fi
    done
}
