package main

import (
	"fmt"
	"net/http"
)

var noredirectHttpClient = &http.Client{
	CheckRedirect: func(req *http.Request, via []*http.Request) error {
		return http.ErrUseLastResponse
	},
}

func checkThreads(u string) error {
	req, err := http.NewRequest("HEAD", u, nil)
	if err != nil {
		return err
	}
	resp, err := noredirectHttpClient.Do(req)
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
	return fmt.Errorf("link header not found")
}
