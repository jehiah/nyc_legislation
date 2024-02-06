// check_social_links verifies that all social links return a HTTP 200 response
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
)

type PersonMetadata struct {
	ID             int
	FullName, Slug string
	District       int
	SocialAccounts []SocialAccount
}

type SocialAccount struct {
	Username string
	Link     string
	Official bool   `json:",omitempty"`
	Personal bool   `json:",omitempty"`
	Platform string // twitter | instagram | facebook | threads
}

func main() {
	log.SetFlags(log.Lshortfile)
	filename := flag.String("people-metadata", "../../people/appendix/people_metadata.json", "path to people_metadata.json")
	flag.Parse()

	f, err := os.OpenFile(*filename, os.O_RDWR, 0755)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	var people []PersonMetadata
	d := json.NewDecoder(f)
	d.DisallowUnknownFields()
	err = d.Decode(&people)
	if err != nil {
		log.Fatal(err)
	}
	var okCount, skipCount int
	var out []PersonMetadata
	for _, p := range people {
		seen := make(map[string]bool)
		social := make([]SocialAccount)
		for _, s := range p.SocialAccounts {
			if seen[s.Link] {
				continue
			}
			seen[s.Link] = true
			var err error
			switch s.Platform {
			case "twitter":
				skipCount++
				social = append(social, s)
				continue
			case "threads":
				err = checkThreads(s.Link)
			default:
				err = checkGeneric(s.Link)
			}
			if err != nil {
				log.Printf("⛔️ %d %s error getting %q %s", p.ID, p.FullName, s.Link, err)
			} else {
				log.Printf("✅ %d %s %s", p.ID, p.FullName, s.Link)
				social = append(social, s)
				okCount++
			}
		}
		p.SocialAccounts = social
		out = append(out, p)
	}

	body, _ := json.MarshalIndent(out, "", "  ")
	f.Truncate(0)
	f.Seek(0, 0)
	f.Write(body)
	fmt.Printf("%s\n", body)

	log.Printf("checked %d social profile links", okCount)
	log.Printf("skipped %d social profile links", skipCount)

}
