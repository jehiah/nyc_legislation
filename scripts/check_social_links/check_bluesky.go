package main

import (
	"fmt"
	"io"
	"net/http"
	"strings"
)

func checkBluesky(u string) error {
	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	code := 0
	if resp != nil {
		code = resp.StatusCode
	}
	if code > 200 {
		return fmt.Errorf("unexpected status %d", code)
	}
	if resp.Header.Get("link") != "" {
		return nil
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if strings.Contains(string(body), `property="og:url"`) {
		return nil
	}
	return fmt.Errorf("og:url profile link not found")
}
