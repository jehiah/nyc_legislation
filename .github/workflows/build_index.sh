#!/bin/sh

mkdir -p build

which -s jq || (echo "missing jq" && exit 1 )

set -e

for YEAR in introduction/????; do 
    # remove fields not needed in the output
    echo "building index $(basename $YEAR).json"
    jq -c -s "map(del(.RTF,.GUID,.BodyID,.EnactmentDate,.PassedDate,.Version,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Text,.Attachments)) | map(.History = ([.History[]? | del(.ActionID,.AgendaSequence,.MinutesSequence,.AgendaNumber,.Version,.MatterStatusID,.EventID,.LastModified,.ID,.BodyID)] ))" $YEAR/????.json > build/$(basename $YEAR).json;
done

echo "building people_active.json"
jq -c -s "map(select(.IsActive) | select(.End | fromdateiso8601 > now) | del(.FirstName,.LastName,.GUID)) | map(.OfficeRecords = ([.OfficeRecords[]? | del(.GUID, .FullName, .PersonID, .LastModified) ]))" people/*.json > build/people_active.json

echo "building people_all.json"
jq -c -s "map(del(.FirstName,.LastName,.GUID)) | map(.OfficeRecords = ([.OfficeRecords[]? | del(.GUID, .FullName, .PersonID, .LastModified) ]))" people/*.json > build/people_all.json

echo "copying people_metadata.json"
cp people/appendix/people_metadata.json build/

echo "building local_laws.json"
# ActionID=58 == City Charter Rule Adopted
# ActionID=57 == Signed Into Law by Mayor
# this History contains the YEAR a local law is from
jq -c -s "map(select(.Attachments[]?.Name | test(\"^Local Law [0-9]+\$\")) | del(.RTF,.Summary,.Text,.IntroDate,.BodyID,.BodyName,.Version,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Sponsors)) | map(.Attachments = ([.Attachments[]? | select(.Name | test(\"^Local Law [0-9]+\$\")) ] )) | map(.History = ([.History[]? | select(.ActionID == 58 or .ActionID == 57)] )) | map(.LocalLaw = .Attachments[0].Name) | map(.LocalLawLink = .Attachments[0].Link) | map( .Year = (.History[0].Date? | fromdateiso8601 | strftime(\"%Y\") | tonumber)) | map(.LocalLawNumber? = (.LocalLaw | split(\" \")[2] | tonumber)) | map(del(.History,.Attachments)) |sort_by(.Year,.LocalLawNumber) "  introduction/????/????.json > build/local_laws.json


# build a legislation index for each active legislator from the current session
for PERSON in people/*.json; do 
    PERSON_ID=$(jq -r "select(.End | fromdateiso8601 > now) | select (.Start | fromdateiso8601 < now) | .ID?" ${PERSON})
    # skip building index for inactive individuals
    if [ -z "${PERSON_ID}" ]; then
        continue
    fi
    echo "building legislation_$(basename $PERSON)"
    if [ -e introduction/2022 ]; then
        jq -c -s "map(select(.Sponsors[]?.ID == ${PERSON_ID})) | map(del(.RTF,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Attachments,.Text, .Version))" introduction/2022/????.json > build/legislation_$(basename $PERSON .json).json;
    else
        jq -c -s "map(select(.Sponsors[]?.ID == ${PERSON_ID})) | map(del(.RTF,.GUID,.TextID,.StatusID,.TypeID,.TypeName,.AgendaDate,.Attachments,.Text, .Version))" introduction/2018/????.json introduction/2019/????.json introduction/2020/????.json introduction/2021/????.json > build/legislation_$(basename $PERSON .json).json;
    fi
done


echo "copying last_sync.json"
cp last_sync.json build/

