#!/bin/sh

mkdir -p build

which -s jq || (echo "missing jq" && exit 1 )

set -e

declare -a RECENT_YEARS
CURRENT_YEAR=$(date +%Y)
START=${START:-"2022"}
while [ $START -le $CURRENT_YEAR ]; do
    RECENT_YEARS+=( "${START}" )
    ((START++))
done
echo "Building YEARS=${RECENT_YEARS[*]} set START=... for a different start year"

for YEAR in ${RECENT_YEARS[*]}; do
    if ! [ -e introduction/$YEAR ]; then
        continue
    fi
    # remove fields not needed in the output
    echo "building index ${YEAR}.json"
    jq -c -s "map(del(.RTF,.GUID,.BodyID,.EnactmentDate,.PassedDate,.Version,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Text,.Attachments)) | map(.History = ([.History[]? | del(.ActionID,.AgendaSequence,.MinutesSequence,.AgendaNumber,.Version,.MatterStatusID,.EventID,.LastModified,.ID,.BodyID,.Votes)] ))" introduction/$YEAR/????.json > build/${YEAR}.json;
    echo "building index ${YEAR}_votes.json"
    jq -c -s "map({File, StatusID, StatusName, Sponsors: ([.Sponsors[]? | {ID}]), History: ([.History[]? | select(.PassedFlagName != null) | {ActionID, Action, PassedFlagName, Votes: [(.Votes[]? | {ID, VoteID} ) ] }])}) " introduction/$YEAR/????.json > build/${YEAR}_votes.json;

done


for YEAR in ${RECENT_YEARS[*]}; do
    if ! [ -e events/$YEAR ]; then
        continue
    fi
    echo "building events_${YEAR}.json"
    jq -c -s "map(del(.GUID,.VideoPath,.VideoStatus,.MinutesFile,.AgendaFile)) | map(.Items = ([.Items[]? | del(.ID,.GUID,.MatterID,.LastModified,.Version,.MinutesNote,.ActionText,.PassedFlag,.RollCall)] ))" events/$YEAR/*.json > build/events_${YEAR}.json;

    echo "building events_attendance_${YEAR}.json"
    jq -c -s "map({ID,BodyID,BodyName,Items}) | map(.Items = ([.Items[]? | select(.RollCallFlag == "1") | del(.ID,.GUID,.MatterID,.LastModified,.Version,.MinutesNote,.ActionText,.PassedFlag,.AgendaSequence,.MinutesSequence) |  .RollCall = ([.RollCall[]? | del(.FullName,.Slug,.Value,.Sort) ]) ] ))" events/$YEAR/*.json > build/events_attendance_${YEAR}.json;
done

echo "building people_active.json"
jq -c -s "map(select(.IsActive) | select(.End | fromdateiso8601 > now) | del(.FirstName,.LastName,.GUID)) | map(.OfficeRecords = ([.OfficeRecords[]? | del(.GUID, .FullName, .PersonID, .LastModified) ]))" people/*.json > build/people_active.json

echo "building people_all.json"
jq -c -s "map(del(.FirstName,.LastName,.GUID)) | map(.OfficeRecords = ([.OfficeRecords[]? | del(.GUID, .FullName, .PersonID, .LastModified) ]))" people/*.json > build/people_all.json

echo "copying people_metadata.json"
cp people/appendix/people_metadata.json build/

echo "building local_laws.json"
# 27 'Introduced by Council',
# 33 'Amended by Committee',
# 32 'Approved by Committee',
# 68 'Approved by Council',
# ActionID=58 == City Charter Rule Adopted
# ActionID=57 == Signed Into Law by Mayor
# 59 == Vetoed by Mayor
# 5084 = Returned Unsigned by Mayor

jq -c -s 'map(select(.LocalLaw) | {File,LocalLaw,Title})' introduction/????/????.json > build/local_laws.json

# build a legislation index for each active legislator from the current session
for PERSON in people/*.json; do 
    PERSON_ID=$(jq -r "select(.End | fromdateiso8601 > now) | select (.Start | fromdateiso8601 < now) | .ID?" ${PERSON})
    # skip building index for inactive individuals
    if [ -z "${PERSON_ID}" ]; then
        continue
    fi
    echo "building legislation_$(basename $PERSON)"
    if [ -e introduction/2024 ]; then
        jq -c -s "map(select(.Sponsors[]?.ID == ${PERSON_ID})) | map(del(.RTF,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Attachments,.Text,.Version)) | map(.History = [(.History[]? | del(.Votes))])" introduction/2024/????.json > build/legislation_$(basename $PERSON .json).json;
    else
        jq -c -s "map(select(.Sponsors[]?.ID == ${PERSON_ID})) | map(del(.RTF,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Attachments,.Text, .Version)) | map(.History = [(.History[]? | del(.Votes))])" introduction/2022/????.json introduction/2023/????.json  > build/legislation_$(basename $PERSON .json).json;
    fi
done

if [ -e introduction/2024 ]; then
    echo "building search_index_2024-2025.json"
    jq -c -s "map({File, Name, Title, Summary, StatusName, LastModified:  ([.History[]? | select(.ActionID == 27 or .ActionID == 33 or .ActionID == 32 or .ActionID == 68 or .ActionID == 58)])[-1]?.Date})" introduction/2024/????.json > build/search_index_2024-2025.json
else
    echo "building search_index_2022-2023.json"
    jq -c -s "map({File, Name, Title, Summary, StatusName, LastModified:  ([.History[]? | select(.ActionID == 27 or .ActionID == 33 or .ActionID == 32 or .ActionID == 68 or .ActionID == 58)])[-1]?.Date})" introduction/2022/????.json introduction/2023/????.json > build/search_index_2022-2023.json
fi

echo "copying last_sync.json"
cp last_sync.json build/

