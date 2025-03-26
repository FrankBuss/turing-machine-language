#!/bin/bash

echo "Running positive tests"

sources=$(find . -name "*.tml" -type f -printf "%f\n")

tests=0
successes=0

for source in $sources; do
    ((tests++))
    rm -f tmp.tm
    rm -f tmp.output
    ../compiler/compiler.exe "$source" tmp.tm
    ../machine/machine.exe tmp.tm "${source}.input" tmp.output
    if ! diff "${source}.output" tmp.output &>/dev/null; then
        echo -e "\e[31mTest failed: $source\e[0m" >&2
        diff "${source}.output" tmp.output
        echo ""
    else
        echo "Test succeeded: $source"
        ((successes++))
    fi
done

echo "Running negative tests"

sources=$(find . -name "*.neg" -type f -printf "%f\n")

for source in $sources; do
    ((tests++))
    rm -f error
    if ! ../compiler/compiler.exe "$source" tmp.tm 2>error; then
        if grep -qi "error" error; then
            echo "Test succeeded: $source"
            ((successes++))
        else
            echo -e "\e[31mTest failed: $source\e[0m" >&2
        fi
    else
        echo -e "\e[31mTest failed: $source\e[0m" >&2
    fi
done

echo "$successes out of $tests succeeded"
