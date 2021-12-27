#!/bin/sh

mkdir -p build

which -s jq || (echo "missing jq" && exit 1 )

set -e

for YEAR in introduction/????; do 
    # remove fields not needed in the output
    echo "building index $(basename $YEAR).json"
    jq -c -s "map(del(.RTF,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Sponsors)) | map(.History = ([.History[]? | del(.ActionID,.AgendaSequence,.MinutesSequence,.AgendaNumber,.Version,.MatterStatusID,.EventID)] ))" $YEAR/????.json > build/$(basename $YEAR).json; 
done

echo "building people_active.json"
jq -c -s "map(select(.IsActive) | del(.FirstName,.LastName,.GUID)) | map(.OfficeRecords = ([.OfficeRecords[]? | del(.GUID, .FullName, .PersonID, .LastModified) ]))" people/*.json > build/people_active.json

echo "building local_laws.json"
# ActionID=58 == City Charter Rule Adopted
# this is contains the YEAR a local law is from
jq -c -s "map(select(.Attachments[]?.Name | contains(\"Local Law \")) | del(.RTF,.Summary,.Text,.IntroDate,.BodyID,.BodyName,.Version,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Sponsors)) | map(.Attachments = ([.Attachments[]? | select(.Name | contains(\"Local Law \")) ] )) | map(.History = ([.History[]? | select(.ActionID == 58)] ))"  introduction/????/????.json > build/local_laws.json