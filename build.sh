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
test() {
    find tests -name "*.csproj" | xargs -n1 dotnet test -c Release --no-build
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
if [[ $# < 1 ]]; then
    help
    exit 1
fi

main "$*"
