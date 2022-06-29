// check_social_links verifies that all social links return a HTTP 200 response
package main

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"os"
)

type PersonMetadata struct {
	ID                           int
	FullName, Slug               string
	District                     int
	Twitter, TwitterPersonal     string
	Facebook, FacebookPersonal   string
	Instagram, InstagramPersonal string
}

func main() {
	log.SetFlags(log.Lshortfile)
	filename := flag.String("people-metadata", "../../people/appendix/people_metadata.json", "path to people_metadata.json")
	flag.Parse()

	f, err := os.Open(*filename)
	if err != nil {
		log.Fatal(err)
	}
	var people []PersonMetadata
	d := json.NewDecoder(f)
	d.DisallowUnknownFields()
	err = d.Decode(&people)
	if err != nil {
		log.Fatal(err)
	}
	okCount := 0
	for _, p := range people {
		for _, l := range []string{p.Twitter, p.TwitterPersonal, p.Facebook, p.FacebookPersonal, p.Instagram, p.InstagramPersonal} {
			if l == "" {
				continue
			}
			resp, err := http.DefaultClient.Get(l)
			code := 0
			if resp != nil {
				code = resp.StatusCode
			}
			if err != nil || code > 200 {
				log.Printf("⛔️ %d %s error getting %q %s StatusCode:%#v", p.ID, p.FullName, l, err, code)
			} else {
				log.Printf("✅ %d %s %s", p.ID, p.FullName, l)
				okCount++
			}
		}
	}
	log.Printf("got HTTP 200 for %d social profile links", okCount)

}
