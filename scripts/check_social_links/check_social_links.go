// check_social_links verifies that all social links return a HTTP 200 response
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"
)

type PersonMetadata struct {
	ID                           int
	FullName, Slug               string
	District                     int
	Twitter, TwitterPersonal     string `json:",omitempty"`
	Facebook, FacebookPersonal   string `json:",omitempty"`
	Instagram, InstagramPersonal string `json:",omitempty"`
	Threads                      string `json:",omitempty"`
	SocialAccounts               []SocialAccount
}

type SocialAccount struct {
	Username string
	Link     string
	Official bool   `json:",omitempty"`
	Personal bool   `json:",omitempty"`
	Platform string // twitter | instagram | facebook | threads
}

func (t PersonMetadata) GetSocialAccounts() []SocialAccount {
	if len(t.SocialAccounts) > 0 {
		return t.SocialAccounts
	}
	accounts := []SocialAccount{
		{Username: twitterUsername(t.Twitter), Link: t.Twitter, Platform: "twitter"},
		{Username: twitterUsername(t.TwitterPersonal), Link: t.TwitterPersonal, Platform: "twitter", Personal: true},
		{Username: facebookUsername(t.Facebook), Link: t.Facebook, Platform: "facebook"},
		{Username: facebookUsername(t.FacebookPersonal), Link: t.FacebookPersonal, Platform: "facebook", Personal: true},
		{Username: instagramUsername(t.Instagram), Link: t.Instagram, Platform: "instagram"},
		{Username: instagramUsername(t.InstagramPersonal), Link: t.InstagramPersonal, Platform: "instagram", Personal: true},
		{Username: instagramUsername(t.Threads), Link: t.Threads, Platform: "threads"},
	}
	if t.Instagram != "" {
		accounts = append(accounts, SocialAccount{
			Username: instagramUsername(t.Instagram),
			Link:     threadsLink(t.Instagram),
			Platform: "threads",
		})
	}
	if t.InstagramPersonal != "" {
		accounts = append(accounts, SocialAccount{
			Username: instagramUsername(t.InstagramPersonal),
			Link:     threadsLink(t.InstagramPersonal),
			Platform: "threads",
			Personal: true,
		})
	}
	var o []SocialAccount
	for _, a := range accounts {
		if a.Link != "" {
			o = append(o, a)
		}
	}
	return o
}

func threadsLink(s string) string {
	s = strings.Replace(s, "https://www.instagram.com/", "https://www.threads.net/@", -1)
	return strings.TrimSuffix(s, "/")
}

func twitterUsername(s string) string {
	if s == "" {
		return ""
	}
	u, err := url.Parse(s)
	if err != nil {
		return ""
	}
	return "@" + strings.TrimPrefix(u.Path, "/")
}
func facebookUsername(s string) string {
	if s == "" {
		return ""
	}
	u, err := url.Parse(s)
	if err != nil {
		return ""
	}
	if strings.Contains(u.Path, "profile.php") {
		return "Facebook"
	}
	return strings.Trim(u.Path, "/")
}
func instagramUsername(s string) string {
	if s == "" {
		return ""
	}
	u, err := url.Parse(s)
	if err != nil {
		return ""
	}
	return strings.Trim(u.Path, "/")
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
		for _, s := range p.GetSocialAccounts() {
			if seen[s.Link] {
				continue
			}
			seen[s.Link] = true
			var err error
			switch s.Platform {
			case "twitter":
				skipCount++
				p.SocialAccounts = append(p.SocialAccounts, s)
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
				p.SocialAccounts = append(p.SocialAccounts, s)
				okCount++
			}
		}
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
