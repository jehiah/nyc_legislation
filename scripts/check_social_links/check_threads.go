package main

import (
	"fmt"
	"net/http"
)

func checkThreads(u string) error {
	req, err := http.NewRequest("HEAD", u, nil)
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
		return fmt.Errorf("unexpeccted status %d", code)
	}
	if resp.Header.Get("link") != "" {
		return nil
	}
	return fmt.Errorf("link header not found")
}
