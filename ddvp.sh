#!/usr/bin/env bash

trap "exit" INT

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ "$4" = "" ] || [ "$5" = "" ]; then
    echo "Usage: ./ddvp.sh <gitURL> <sha> <victim> <polluter> <package> (<module>)"
    exit 1;
fi

cwd="$(pwd)"
scriptDir="$(dirname "$0")"
gitURL="$1"
gitRepoName="$(basename "$gitURL" .git)"
sha="$2"
victim="$3"
polluter="$4"

if [[ -z "${NO_CLONE}" ]]; then
    git clone "$gitURL"
    cd "$gitRepoName"
    git checkout "$sha"
fi

if [[ -n "${6}" ]]; then
    module="$6"
    [[ -z "${NO_INSTALL}" ]] && mvn install -pl "$module" -am -Dmaven.test.skip=true -Ddependency-check.skip=true -Dmaven.javadoc.skip=true
    cd "$module"
else
    [[ -z "${NO_INSTALL}" ]] && mvn install -Dmaven.test.skip=true -Ddependency-check.skip=true -Dmaven.javadoc.skip=true
fi

if [[ -z "${NO_TEST}" ]]; then
    printf "\n\n\n\n\033[0;31mTest Run (Should Fail):\033[0m\n"
    if java -cp "./target/dependency/*:./target/classes:./target/test-classes:$scriptDir/runner-1.0-SNAPSHOT.jar" in.natelev.runner.Runner "$polluter" "$victim"; then
        printf "\n\n\033[0;31mERR: Test PV run did not fail!\033[0m Are the polluter and victim switched?\n"
        exit 1;
    fi
    printf "\n\n\n\n"
fi

if [[ -z "${NO_GEN}" ]]; then
    INSTRUMENT_ONLY="$5" PPT_SELECT="$5" "$scriptDir/daikon-gen-victim-polluter.sh" "$victim" "$polluter"
fi

"$scriptDir/daikon-diff-victim-polluter.sh" -o "$cwd/$gitRepoName.dinv"

if [[ -n "${CREATE_GISTS}" ]]; then
    CLIARGS="$@"
    cp "$cwd/$gitRepoName.dinv" "$cwd/!-$gitRepoName.dinv"
    gh gist create "$cwd/!-$gitRepoName.dinv" daikon-pv.log daikon-victim.log daikon-polluter.log --web --desc "Generated by ddvp.sh: ./ddvp.sh $CLIARGS"
    rm "$cwd/!-$gitRepoName.dinv"
fi

echo -e "\x1B[32m✓ Completed DDVP. Took ""$SECONDS""s.\x1B[0m"