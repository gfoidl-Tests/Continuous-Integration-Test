#!/bin/bash
#------------------------------------------------------------------------------
set -e
#------------------------------------------------------------------------------
help() {
    echo "build script"
    echo ""
    echo "Arguments:"
    echo "  build                  builds the solution"
    echo "  test                   runs all tests under ./tests"
    echo "  deploy [nuget|myget]   deploys to the destination"
}
#------------------------------------------------------------------------------
build() {
    # ci tools clone usually to depth 50, so this is not good
    #export BuildNumber=$(git log --oneline | wc -l)
    export BuildNumber=$CI_BUILD_NUMBER
    export VersionSuffix="preview-$CI_BUILD_NUMBER"

    if [[ -n "$TAG_NAME" ]]; then
        if [[ "$TAG_NAME" =~ ^v[0-9]\.[0-9]\.[0-9]$ ]]; then
            unset VersionSuffix
        fi
    fi
    
    echo "BuildNumber: $BuildNumber"
    echo "VersionSuffix: $VersionSuffix"
    echo ""

    dotnet restore
    dotnet build -c Release --no-restore
}
#------------------------------------------------------------------------------
testCore() {
    local testFullName
    local testDir
    local testName
    local testResultName

    testFullName="$1"
    testDir=$(dirname "$testFullName")
    testName=$(basename "$testFullName")
    testResultName="$testName-$(date +%s).trx"

    echo ""
    echo "test fullname:    $testFullName"
    echo "testing:          $testName..."
    echo "test result name: $testResultName"
    echo ""
    
    dotnet test -c Release --no-build --logger "trx;LogFileName=$testResultName" "$testFullName"

    local result=$?

    mkdir -p "./tests/TestResults"
    mv "$testDir/TestResults/$testResultName" "./tests/TestResults/$testResultName"

    if [[ $result != 0 ]]; then
        exit $result
    fi
}
#------------------------------------------------------------------------------
test() {
    export -f testCore
    find tests -name "*.csproj" -print0 | xargs -0 -n1 bash -c 'testCore "$@"' _
}
#------------------------------------------------------------------------------
deployCore() {
    dotnet pack -o "$(pwd)/NuGet-Packed" --no-build -c Release "source/$NAME"
    
    if [[ -z "$DEBUG" ]]; then
        dotnet nuget push --source "$1" --api-key "$2" -t 60 ./NuGet-Packed/*.nupkg
    else
        echo "DEBUG: simulate nuget push to $1"
    fi

    ls -l ./NuGet-Packed    
}
#------------------------------------------------------------------------------
deploy() {
    if [[ "$1" == "nuget" ]]; then
        deployCore "$NUGET_FEED" "$NUGET_KEY"
    elif [[ "$1" == "myget" ]]; then
        deployCore "$MYGET_FEED" "$MYGET_KEY"
    else
        echo "Unknows deploy target '$1', aborting"
        exit 1
    fi
}
#------------------------------------------------------------------------------
main() {
    case "$1" in
        build)  build
                ;;
        test)   test
                ;;
        deploy)
                shift
                deploy "$2"
                ;;
    esac
}
#------------------------------------------------------------------------------
if [[ $# -lt 1 ]]; then
    help
    exit 1
fi

main "$*"
