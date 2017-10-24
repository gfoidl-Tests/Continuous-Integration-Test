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
setBuildEnv() {
    if [[ -z "$NAME" ]]; then
        echo "NAME environment variable must be set to project-name (for packaging)"
        exit 1
    fi

    if [[ -z "$CI_BUILD_NUMBER" ]]; then
        if [[ -n "$CIRCLECI" ]]; then
            export CI_BUILD_NUMBER=$CIRCLE_BUILD_NUM
            export BRANCH_NAME=$CIRCLE_BRANCH
            export TAG_NAME=$CIRCLE_TAG
        elif [[ -n "$TRAVIS" ]]; then
            export CI_BUILD_NUMBER=$TRAVIS_BUILD_NUMBER
            export BRANCH_NAME=$(if [[ -n "$TRAVIS_PULL_REQUEST_BRANCH" ]]; then echo "$TRAVIS_PULL_REQUEST_BRANCH"; else echo "$TRAVIS_BRANCH"; fi)
            export TAG_NAME=$TRAVIS_TAG
        elif [[ -n "$BITBUCKET_BUILD_NUMBER" ]]; then
            export CI_BUILD_NUMBER=$BITBUCKET_BUILD_NUMBER
            export BRANCH_NAME=$BITBUCKET_BRANCH
            export TAG_NAME=$BITBUCKET_TAG
        fi
    fi

    # BuildNumber is used by MsBuild for version information.
    # ci tools clone usually to depth 50, so this is not good
    #export BuildNumber=$(git log --oneline | wc -l)
    export BuildNumber=$CI_BUILD_NUMBER
    export VersionSuffix="preview-$CI_BUILD_NUMBER"

    if [[ -n "$TAG_NAME" ]]; then
        if [[ "$TAG_NAME" =~ ^v[0-9]\.[0-9]\.[0-9]$ ]]; then
            unset VersionSuffix
        fi
    fi
    
    echo "-------------------------------------------------"
    echo "Branch:        $BRANCH_NAME"
    echo "Tag:           $TAG_NAME"
    echo "BuildNumber:   $BuildNumber"
    echo "VersionSuffix: $VersionSuffix"
    echo "-------------------------------------------------"
}
#------------------------------------------------------------------------------
build() {
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

    ls -l ./NuGet-Packed
    echo ""

    if [[ -z "$DEBUG" ]]; then
        dotnet nuget push --source "$1" --api-key "$2" -t 60 ./NuGet-Packed/*.nupkg
    else
        echo "DEBUG: simulate nuget push to $1"
    fi
}
#------------------------------------------------------------------------------
deploy() {
    if [[ -n "$CI_SKIP_DEPLOY" ]]; then
        echo "Skipping deploy because CI_SKIP_DEPLOY is set"
        return
    fi

    if [[ "$1" == "nuget" ]]; then
        deployCore "$NUGET_FEED" "$NUGET_KEY"
    elif [[ "$1" == "myget" ]]; then
        deployCore "$MYGET_FEED" "$MYGET_KEY"
    else
        echo "Unknown deploy target '$1', aborting"
        exit 1
    fi
}
#------------------------------------------------------------------------------
main() {
    setBuildEnv

    case "$1" in
        build)  build
                ;;
        test)   test
                ;;
        deploy)
                shift
                deploy "$1"
                ;;
        *)
                help
                exit
                ;;
    esac
}
#------------------------------------------------------------------------------
if [[ $# -lt 1 ]]; then
    help
    exit 1
fi

main $*
